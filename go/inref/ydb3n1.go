//////////////////////////////////////////////////////////////////
//
// Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.
// All rights reserved.
//
//	This source code contains the intellectual property
//	of its copyright holder(s), and is made available
//	under a license.  If you do not know the terms of
//	the license, please stop and do not read further.
//
//////////////////////////////////////////////////////////////////

// YottaDB Golang client implementing 3n+1 sequence calculation

package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"math"
	_ "net/http/pprof"
	"os"
	"os/exec"
	"runtime"
	"runtime/pprof"
	"strconv"
	"strings"
	"sync"
	"time"

	"golang.org/x/text/language"
	"golang.org/x/text/message"
	"lang.yottadb.com/go/yottadb/v2"
)

// Setup command-line options
var subprocessNum int
var useGoroutines bool
var profiling bool
var manyWorkers bool
var errlog, outlog string

func init() {
	flag.IntVar(&subprocessNum, "subprocess", -1, "Start the process as a subprocess of the main ydb3n1 program and give it the supplied worker number (integer)")
	// Using goroutines (below) is slower because the YottaDB process itself has a thread lock so even though
	// the Go logic might be a little faster with Goroutines, the YottaDB portion cannot be performed in parallel
	//when called from multiple Goroutines.
	flag.BoolVar(&useGoroutines, "usegoroutines", false, "Use Goroutines instead of processes.")
	flag.BoolVar(&profiling, "profiling", false, fmt.Sprintf("Turn on profiling web server for flamegraph analysis. Collect and view it with: 'go tool pprof -http=:9090 %s ydb3n1-*.prof", os.Args[0]))
	flag.BoolVar(&manyWorkers, "manyworkers", false, "Create a new worker for each block of sequences, but still limit to specificed max workers at any one time")
	flag.StringVar(&outlog, "outlog", "", "Filename prefix for files that will accept child process's output logs instead of parent's stdout")
	flag.StringVar(&errlog, "errlog", "", "Filename prefix for files that will accept child process's error logs instead of parent's stderr")
}

const resolution time.Duration = 1 * time.Millisecond // length of sleeps while waiting for all processes to start: does NOT determine resolution of duration result
const startupTimeout time.Duration = 3 * time.Second  // how long to wait for all processes to start up before giving a warning

// ShareData is shared for all functions in this module running in one goroutine. Other goroutines have their own copy.
type ShareData struct {
	conn           *yottadb.Conn
	reads, updates int
	// Here I use capital letters to distinguish database node objects (e.g. Reads) from shared variables (e.g. reads)
	Blocks, Block, Worker, Finished, Queued, Trigger, Reads, Updates *yottadb.Node  // Normal nodes
	Step, Longest, Highest                                           *MonitoredNode // Monitored nodes (which count reads and updates)
	// Define functions for trigger and finisher -- to be set later depending on -- usegoroutines option
	triggerPrime, triggerFire, triggerWait    func()
	finishedPrime, finishedDone, finishedWait func()
}

var printer *message.Printer = message.NewPrinter(language.English) // print %d numbers with thousands separators

// This section Subclasses conn.Node so we can automatically count get/set operations
type MonitoredNode struct {
	*yottadb.Node
	G *ShareData
}

// Return monitored version of node n.
func (G *ShareData) Monitored(n *yottadb.Node) (mn *MonitoredNode) {
	return &MonitoredNode{n, G}
}

// Redefine node methods to count reads and updates.
func (n *MonitoredNode) GetInt() int {
	n.G.reads++
	return n.Node.GetInt()
}
func (n *MonitoredNode) Set(val any) {
	n.G.updates++
	n.Node.Set(val)
}
func (n *MonitoredNode) HasNone() bool {
	n.G.reads++
	return n.Node.HasNone()
}
func (n *MonitoredNode) Index(val any) *MonitoredNode {
	// Mutate overridden so that MonitoredNode's mutated offspring remain type MonitoredNode
	return &MonitoredNode{n.Node.Index(val), n.G}
}

// sequence is the core 3n1 calculation function.
// It follows the 3n+1 'path' to 1 and stores each step in 'Step'.
func (G *ShareData) sequence(n int) {
	highest, currpath := 0, []int{}
	for n > 1 && G.Step.Index(n).HasNone() {
		currpath = append(currpath, n) // log n as current number in sequence
		// compute the next number
		if n&1 > 0 {
			n = 3*n + 1
		} else {
			n = n / 2
		}
		highest = max(n, highest) // update highest if necessary
	}
	steps := len(currpath)
	if steps == 0 {
		return // if steps=0 we already have an answer for n
	}
	if n > 1 {
		steps = steps + G.Step.Index(n).GetInt() // if n>1 then Step[n] has #steps remaining so add => total steps in path
	}
	G.conn.TransactionFast(nil, func() {
		if steps > G.Longest.GetInt() {
			G.Longest.Set(steps) // update longest
		}
		if highest > G.Highest.GetInt() {
			G.Highest.Set(highest) // update highest
		}
	})
	// Now that we know how many steps in this entire path, we can fill up the 'Step' database hashtable
	for i, value := range currpath {
		G.Step.Index(value).Set(steps - i)
	}
}

// nextblock starts the next block of numbers from G.Blocks[G.Block] to G.Blocks[G.Block+1]
func (G *ShareData) nextblock() {
	// Process the next block in `Blocks` that needs processing; quit when no more blocks to process.
	// G.Block holds the index of the previous block claimed by a job for processing.
	for block := G.Block.IncrInt(1); !G.Blocks.Index(block + 1).HasNone(); block = G.Block.IncrInt(1) {
		first := G.Blocks.Index(block).GetInt() + 1
		last := G.Blocks.Index(block + 1).GetInt()
		for n := first; n <= last; n++ {
			G.sequence(n)
		}
		// if we're doing a new worker per block then don't loop; just create a new fork if there are any blocks left to compute
		if manyWorkers && !G.Blocks.Index(G.Block.GetInt()+2).HasNone() {
			G.Queued.Incr(1) // say we've started another process
			fork(G.Worker.IncrInt(1))
			break
		}
	}
}

// subprocess is the entrypoint for worker processes
func (G *ShareData) subprocess(worker int) {
	G.finishedPrime() // Tell main routine to wait for us
	G.Queued.Incr(-1) // tell parent I'm ready to start
	G.triggerWait()

	// Profile all processes.
	if profiling {
		func() {
			// Create a file to write the profile data
			// Get pid of the master process to use as a number in the filename
			pid := os.Getpid()
			if subprocessNum != -1 {
				pid = os.Getppid()
			}
			f, err := os.Create(fmt.Sprintf("ydb3n1-%d.%d.prof", pid, worker))
			if err != nil {
				log.Fatal("could not create profiling file", err)
			}
			defer f.Close()

			// Start profiling on this thread
			if err := pprof.StartCPUProfile(f); err != nil {
				log.Fatal("could not start profiling", err)
			}
			// Automatically stop when this thread/function exits
			defer pprof.StopCPUProfile()

			G.nextblock()
		}()
	} else {
		G.nextblock()
	}

	// add the number of reads & write performed by this process to that of all processes
	G.Reads.Incr(G.reads)
	G.Updates.Incr(G.updates)
	G.finishedDone() // Tell main routine this worker is done
}

// fork runs subprocess() either as a Goroutine or it re-runs the current program as a subprocess to perform as the specified worker number.
// Returns a process described by exec.Cmd
func fork(worker int) *exec.Cmd {
	if useGoroutines {
		go func() {
			conn := yottadb.NewConn()
			G := setup(conn)
			G.subprocess(worker)
		}()
		return nil
	}
	executable := os.Args[0]
	commandStrings := []string{executable, fmt.Sprintf("--subprocess=%d", worker)}
	// Append all user-specified flags as flags to the subprocess, too
	flag.Visit(func(f *flag.Flag) { commandStrings = append(commandStrings, fmt.Sprintf("--%s=%s", f.Name, f.Value)) })
	process := exec.Command(commandStrings[0], commandStrings[1:]...)
	stdout, stderr := os.Stdout, os.Stderr
	var err error
	if outlog != "" {
		stdout, err = os.Create(fmt.Sprintf("%s-%d.out", outlog, worker))
		if err != nil {
			panic(err)
		}
	}
	if errlog != "" {
		if errlog == outlog {
			stderr = stdout
		} else {
			stderr, err = os.Create(fmt.Sprintf("%s-%d.out", errlog, worker))
			if err != nil {
				panic(err)
			}
		}
	}
	process.Stdout, process.Stderr = stdout, stderr // Make subprocess output to the parent's terminal
	err = process.Start()
	if err != nil {
		panic(err)
	}
	return process
}

// manageWorkers starts/stops worker processes, each with a block of numbers
func (G *ShareData) manageWorkers(nWorkers int, blocks []int) time.Duration {
	G.Blocks.Kill() // delete all blocks
	for i, value := range blocks {
		G.Blocks.Index(i + 1).Set(value) // store blocks array into database
	}
	G.Block.Set(-1)  // index into ^blocks; gets incremented before first use
	G.Worker.Set(-1) // index of next worker; gets incremented before first use
	G.triggerPrime() // grab lock so processes all wait for it and start together when we release this trigger
	// Launch `workers` jobs that will each successively process blocks of numbers.
	// Each child sets dbase worker[PID] and then decrements queued to flag that it has started.
	G.Queued.Set(nWorkers) // how many we'll start
	parentWorker := 1
	if manyWorkers {
		parentWorker = 0
	}
	procs := make([]*exec.Cmd, nWorkers-parentWorker)
	for worker := range procs { // don't create last worker which will be the parent process
		procs[worker] = fork(G.Worker.IncrInt(1))
	}
	// wait up to n seconds for jobs to start and decrement `Queued`
	stop := time.Now().Add(startupTimeout)
	for G.Queued.GetInt() != parentWorker { // parentWorker should remain unstarted for main routine to run below
		if time.Now().After(stop) {
			fmt.Printf("Warning: %d jobs did not start immediately, possibly due to insufficient lock space.\n", G.Queued.GetInt()-1)
			fmt.Printf("You should increase lock space with `mupip set -region default -lock_space=<max_workers>`\n")
			fmt.Printf("Otherwise duration will be extra long due to YDB slow-polling for last job completion.\n")
			break
		}
		time.Sleep(resolution)
	}
	G.triggerFire() // start queued processes
	// Now wait for workers to finish and delete their PIDs, and finally we print results.
	start := time.Now()
	if parentWorker == 1 {
		G.subprocess(G.Worker.IncrInt(1)) // run last worker in *this* process (easier debugging when 1 process on stdout)
	}
	// Sleep until all workers are done.
	G.finishedWait()
	// Repeat to prevent race condition where a child process says it's finished before grandchild process can start up
	for G.Queued.Get() != "0" {
		G.finishedWait()
	}

	if !useGoroutines {
		// Wait for all worker processes to finish
		// Note: this does not wait for grandchild processes created if --worker-per-block is used
		// because even os.Process.Wait() does not work on grandchildren.
		// This is hopefully not serious because we've already waited for every process to finish using G.finishedWait().
		// However, there is a chance the grandchild process won't finish running down the database before it is terminated.
		// To wait for grandchildren we'd have to create OS-level signal groups. Alternatively, the parent could create all processes
		// (the latter would require a trigger to wake up the parent when a process is finished so another can be created).
		// For now, this will do.
		for _, proc := range procs {
			if err := proc.Wait(); err != nil {
				panic(err)
			}
		}
	}
	return time.Now().Sub(start)
}

// DoInputLine obeys each line of input
func (G *ShareData) DoInputLine(line string) {
	values := []int{-1, -1, -1}
	i := 0
	for arg := range strings.SplitSeq(line, " ") {
		num, err := strconv.Atoi(arg)
		if err != nil {
			panic(fmt.Errorf("%w: input line '%s' parameter `%s` must be a number\n", err, line, arg))
		}
		values[i] = num
		i++
	}
	maxN, workers, blocksize := values[0], values[1], values[2]
	if maxN < 0 {
		return // do nothing on blank lines
	}
	if workers < 0 {
		workers = 2 * runtime.NumCPU() // default number of workers
	}
	if blocksize < 0 {
		maximum := (maxN - 1 + workers) / workers // default = maximum block size
		blocksize = min(maximum, int(math.Ceil(float64(maximum)/8)))
	}
	blocks := delineateBlocks(maxN, blocksize)   // create slice of blocks of numbers to process
	duration := G.manageWorkers(workers, blocks) // start/stop worker processes, each with a block of numbers
	printer.Printf("1->%d /%d ", maxN, workers)
	G.printout(blocksize, duration)
	if manyWorkers {
		printer.Printf("%d blocks completed in separate processes\n", G.Worker.GetInt())
	}
	G.dbInit()
}

// delineateBlocks returns a slice of numbers to process
func delineateBlocks(maxN, blocksize int) []int {
	blocks := []int{}
	for next := 0; next <= maxN; next += blocksize {
		blocks = append(blocks, next)
	}
	if blocks[len(blocks)-1] != maxN {
		blocks = append(blocks, maxN)
	}
	return blocks
}

// dbInit cleans the dbase before starting the next run
func (G *ShareData) dbInit() {
	G.reads, G.updates = 0, 0
	G.Reads.Kill()
	G.Updates.Kill()
	G.Highest.Kill()
	G.Longest.Kill() // cf. printout() function for use for these values
	G.Step.Kill()    // step is the path lookup table: each subscript is # steps to 1 from here
}

// printout displays the results
func (G *ShareData) printout(blocksize int, duration time.Duration) {
	seconds := duration.Seconds()
	reads, updates, longest, highest := G.Reads.GetInt(), G.Updates.GetInt(), G.Longest.GetInt(), G.Highest.GetInt()
	printer.Printf("blocksize=%d longest=%d highest=%d duration=%.3f updates=%d reads=%d ", blocksize, longest, highest, seconds, updates, reads)
	if seconds > 0 {
		printer.Printf("updates/s=%d reads/s=%d ", int(float64(updates)/seconds), int(float64(reads)/seconds))
	}
	printer.Printf("\n")
}

var trigger sync.WaitGroup  // global trigger to get all Goroutines to start at the same time (if using Goroutines)
var finished sync.WaitGroup // global finisher to check when Goroutines have finished (if using Goroutines)

// setup connects Go global names to database access objects
func setup(conn *yottadb.Conn) *ShareData {
	G := ShareData{}
	G.conn = conn
	// non-monitored nodes (reads/updates not counted):
	G.Blocks = conn.Node("^blocks")
	G.Block = conn.Node("^block")   // index into ^blocks
	G.Worker = conn.Node("^worker") // index of next worker within ^workers
	G.Finished = conn.Node("^finished")
	G.Queued = conn.Node("^queued")
	G.Trigger = conn.Node("^trigger") // Node access to process-level YottaDB Lock (if not using Goroutines)
	G.Reads = conn.Node("^reads")
	G.Updates = conn.Node("^updates")
	// monitored nodes (reads/updates counted):
	G.Longest = G.Monitored(conn.Node("^longest"))
	G.Highest = G.Monitored(conn.Node("^highest"))
	G.Step = G.Monitored(conn.Node("^step"))

	// Decide whether to use YDB lock functions or Go WaitGroup functions for locking.
	// YottaDB locks only work for processes and Go WaitGroups only work for Goroutines.
	if useGoroutines {
		// trigger is used to start all goroutines at the same time
		G.triggerPrime = func() { trigger.Add(1) }
		G.triggerFire = func() { trigger.Done() }
		G.triggerWait = func() { trigger.Wait() }
		// finished locks can be handled the same way as above for Goroutines, but not for YottaDB locks (see below)
		G.finishedPrime = func() { finished.Add(1) }
		G.finishedDone = func() { finished.Done() }
		G.finishedWait = func() { finished.Wait() }
	} else {
		// trigger is used to start all processes at the same time via YottaDB hierarchical locks.
		G.triggerPrime = func() { G.Trigger.Lock() }
		G.triggerFire = func() { G.Trigger.Unlock() }
		G.triggerWait = func() { G.Trigger.Index(os.Getpid()).Lock(); G.Trigger.Index(os.Getpid()).Unlock() } // get lock on trigger[PID] only when parent has released lock on Trigger
		// Cannot use the same functions for finished as for trigger above because we're waiting for many rather than one.
		// With hierarchical locks the 'many' must be in the child nodes, whether waiting or priming.
		// For triggering it's waiting on one; for finishing we're waiting on the 'many', so it's the opposite of the trigger above.
		G.finishedPrime = func() { G.Finished.Index(os.Getpid()).Lock() }
		G.finishedDone = func() { G.Finished.Index(os.Getpid()).Unlock() }
		G.finishedWait = func() { G.Finished.Lock(); G.Finished.Unlock() } // getting lock on parent node won't succeed until all children trigger[PID] nodes are unlocked
	}
	return &G
}

func main() {
	flag.Parse() // parse command line

	log.SetFlags(log.Lmicroseconds + log.Lmsgprefix)
	log.SetPrefix("Parent: ")

	defer yottadb.Shutdown(yottadb.MustInit())
	conn := yottadb.NewConn()
	if subprocessNum != -1 {
		log.SetPrefix(fmt.Sprintf("Worker %d: ", subprocessNum))
		log.SetFlags(log.Lmicroseconds + log.Lmsgprefix)
		G := setup(conn)
		G.subprocess(subprocessNum)
		return
	}
	G := setup(conn)
	if len(flag.Args()) > 0 {
		G.dbInit()
		G.DoInputLine(strings.Join(flag.Args(), " "))
	} else {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			G.DoInputLine(scanner.Text())
		}
	}
	if profiling {
		// Output filename last so user can get it with `tail -n1` and use it to automatically display the profile
		fmt.Printf("Merge and process profiles with 'f=$(%s -profiling 1000000 4 |& tee /dev/tty | tail -1) && go tool pprof -http=:9090 $f'\n", os.Args[0])
		fmt.Printf("%s ydb3n1-%d.*.prof\n", os.Args[0], os.Getpid())
	}
}

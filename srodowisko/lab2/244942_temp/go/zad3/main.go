package main

import (
	. "./settings"
	"container/list"
	"fmt"
	"math/rand"
	"strconv"
	"time"
)

type job struct{
	firstArg int
	secondArg int
	operand string
	result *int
}

type jobAssignment struct{
	newJob job
	response chan bool
}

type jobRequest struct{
	response chan job
}

type productDeposit struct{
	product int
	response chan bool
}

type purchase struct{
	response chan int
}

type stateRequest struct{
	response chan string
}

type responseRequest struct{
	response chan bool
}

func intSentry(b bool, c chan int) chan int{
	if b{
		return c
	}
	return nil
}

func jobAssignmentSentry(b bool, c chan jobAssignment) chan jobAssignment{
	if b {
		return c
	}
	return nil
}

func jobRequestSentry(b bool, c chan jobRequest) chan jobRequest{
	if b {
		return c
	}
	return nil
}

func productDepositSentry(b bool, c chan productDeposit) chan productDeposit{
	if b {
		return c
	}
	return nil
}

func purchaseSentry(b bool, c chan purchase) chan purchase{
	if b {
		return c
	}
	return nil
}

func loudPrint(str string){
	if LoudMode {
		fmt.Println(str)
	}
}

func boss(jobAssignments chan<- jobAssignment){
	operands := [3]string{"+","*"}
	for{
		var newJobAssignment jobAssignment
		newJobAssignment.newJob.firstArg = rand.Int()%1024
		newJobAssignment.newJob.secondArg = rand.Int()%1024
		newJobAssignment.newJob.operand = operands[rand.Int()%2]
		newJobAssignment.newJob.result = nil
		newJobAssignment.response = make(chan bool)
		jobAssignments <- newJobAssignment
		<-newJobAssignment.response
		loudPrint("Boss: " + strconv.Itoa(newJobAssignment.newJob.firstArg) + " " + newJobAssignment.newJob.operand + " " + strconv.Itoa(newJobAssignment.newJob.secondArg))
		time.Sleep(time.Duration(BossSleep - BossVariance + 2*rand.Float64()*BossVariance) * time.Second)
	}
}

func jobList(jobAssignments chan jobAssignment, jobRequests chan jobRequest, stateRequests <-chan stateRequest){
	jobs := list.New()
	for{
		select {
		case sr := <-stateRequests:
			var s string
			j := jobs.Front()
			for j != nil{
				s = s + strconv.Itoa(j.Value.(job).firstArg) + " " + j.Value.(job).operand + " " + strconv.Itoa(j.Value.(job).secondArg) + "\n"
				j = j.Next()
			}
			sr.response <- s
		case jobAssignment := <-jobAssignmentSentry(jobs.Len() < MaxJobs,jobAssignments) :
			jobs.PushBack(jobAssignment.newJob)
			jobAssignment.response <- true
		case jobRequest := <-jobRequestSentry(jobs.Len() > 0,jobRequests) :
			jobRequest.response <- jobs.Front().Value.(job)
			jobs.Remove(jobs.Front())
		}
	}
}

func additionMachine(id int, jaChannel <-chan *jobAssignment, maintenanceChan <-chan responseRequest){
	broken := false
	for{
		select {
		case r := <- maintenanceChan:
			if broken {
				time.Sleep(RepairTime)
				broken = false
				r.response <- true
			} else {
				r.response <- true
			}
		case currJob := <-jaChannel:
			time.Sleep(MachineWorkTime)
			if broken{
				currJob.newJob.result = nil
			} else {
				currJob.newJob.result = new(int)
				*currJob.newJob.result = currJob.newJob.firstArg + currJob.newJob.secondArg
				broken = rand.Float64() < BreakChance
			}
			currJob.response <- true
		}
	}
}

func multiplicationMachine(id int, jaChannel <-chan *jobAssignment, maintenanceChan <-chan responseRequest){
	broken := false
	for{
		select {
		case r := <- maintenanceChan:
			if broken {
				time.Sleep(RepairTime)
				broken = false
				r.response <- true
			} else {
				r.response <- true
			}
		case currJob := <-jaChannel:
			time.Sleep(MachineWorkTime)
			if broken{
				currJob.newJob.result = nil
			} else {
				currJob.newJob.result = new(int)
				*currJob.newJob.result = currJob.newJob.firstArg * currJob.newJob.secondArg
				broken = rand.Float64() < BreakChance
			}
			currJob.response <- true
		}
	}
}

func worker(id int, jobRequests chan<- jobRequest,depoosits chan<- productDeposit, aQueues []chan *jobAssignment, mQueues []chan *jobAssignment, jobCounts []int, patient []bool, reports chan<- int) {
	jobCounts[id-1] = 0
	patient[id-1] = rand.Int()%2 == 1
	for {
		req := jobRequest{response: make(chan job)}
		jobRequests <- req
		ja := jobAssignment{
			newJob:<-req.response,
			response:make(chan bool)}
		switch ja.newJob.operand {
		case "+":
			for ja.newJob.result == nil {
				randQueue := rand.Int()%AdditionMachines
				if patient[id-1] {
					aQueues[randQueue] <- &ja
				} else {
					waiting := true
					for waiting {
						select {
						case aQueues[randQueue] <- &ja:
							waiting = false
						case <-time.After(ImpatientInterval):
							randQueue = rand.Int()%AdditionMachines
						}
					}
				}
				<-ja.response
				if ja.newJob.result == nil {
					reports <- randQueue
				}
			}
			d := productDeposit{
				product: *ja.newJob.result,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
		case "*":
			for ja.newJob.result == nil {
				randQueue := rand.Int()%MultiplicationMachines
				if patient[id-1] {
					mQueues[rand.Int()%MultiplicationMachines] <- &ja
				} else {
					waiting := true
					for waiting {
						select {
						case mQueues[randQueue] <- &ja:
							waiting = false
						case <-time.After(ImpatientInterval):
							randQueue = rand.Int()%MultiplicationMachines
						}
					}
				}
				<-ja.response
				if ja.newJob.result == nil {
					reports <- AdditionMachines + randQueue
				}
			}
			d := productDeposit{
				product: *ja.newJob.result,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
		default:
			panic("wrong operand")
		}
		jobCounts[id-1]++
		loudPrint("Worker " + strconv.Itoa(id) + ": " + strconv.Itoa(ja.newJob.firstArg) + ja.newJob.operand + strconv.Itoa(ja.newJob.secondArg) + " = " + strconv.Itoa(*ja.newJob.result))
		//time.Sleep(time.Duration(WorkerSleep - WorkerVariance + 2*rand.Float64()*WorkerVariance) * time.Second)
	}
}

func warehouse(deposits chan productDeposit, purchases chan purchase, stateRequests <-chan stateRequest){
	products := list.New()
	for{
		select {
		case sr := <-stateRequests:
			var s string
			p := products.Front()
			for p != nil{
				s = s + strconv.Itoa(p.Value.(int)) + "\n"
				p = p.Next()
			}
			sr.response <- s
		case d := <-productDepositSentry(products.Len() < WarehouseThreshold,deposits) :
			products.PushBack(d.product)
			d.response <- true
		case p := <-purchaseSentry(products.Len() > 0,purchases) :
			toSell := products.Front()
			cap := rand.Int()%products.Len()
			for i := 0; i < cap; i++{
				toSell = toSell.Next()
			}
			p.response <- toSell.Value.(int)
			products.Remove(toSell)
		}
	}
}

func client(purchases chan<- purchase){
	for{
		p := purchase{response: make(chan int)}
		purchases <- p
		bought := <-p.response
		loudPrint("Client: " + strconv.Itoa(bought))
		time.Sleep(time.Duration(ClientSleep - ClientVariance + 2*rand.Float64()*ClientVariance) * time.Second)
	}
}

func maintenance(reports chan int, maintenanceChans []chan responseRequest){
	available := MaintenanceWorkers
	machineRepair := make([]bool,AdditionMachines+MultiplicationMachines)
	returns := make(chan int)
	for i := range machineRepair {
		machineRepair[i] = false
	}
	for {
		select {
		case id := <-intSentry(available > 0,reports):
			if !machineRepair[id] {
				loudPrint("Maintenance: sending repair to " + strconv.Itoa(id))
				go maintenanceWorker(id,maintenanceChans[id],returns)
				machineRepair[id] = true
				available--
			}
		case id := <-returns:
			machineRepair[id] = false
			available++
		}
	}
}

func maintenanceWorker(id int, maintenanceChan chan<- responseRequest, returns chan<- int){
	r := responseRequest{response: make(chan bool)}
	time.Sleep(RepairmanArrivalTime)
	maintenanceChan <- r
	<-r.response
	returns <- id
}

func calmMode(jobListChannel chan<- stateRequest, warehouseChannel chan<- stateRequest, jobCounts []int, patient []bool){
	var input string
	var id int
	for {
		fmt.Scanf("%s",&input)
		switch input {
		case "jobs":
			req := stateRequest{response:make(chan string)}
			jobListChannel <- req
			fmt.Printf(<-req.response)
		case "products":
			req := stateRequest{response:make(chan string)}
			warehouseChannel <- req
			fmt.Printf(<-req.response)
		case "worker":
			fmt.Scanf("%d",&id)
			if patient[id-1] {
				fmt.Printf("Worker " + strconv.Itoa(id) + ": patient, completed " + strconv.Itoa(jobCounts[id-1]) + " jobs.\n")
			} else {
				fmt.Printf("Worker " + strconv.Itoa(id) + ": impatient, completed " + strconv.Itoa(jobCounts[id-1]) + " jobs.\n")
			}
		default:
			fmt.Printf("Incorrect input.")
		}
	}
}

func main(){
	fmt.Println("Hello World!")
	jobAssignments := make(chan jobAssignment,20)
	jobRequests := make(chan jobRequest,20)
	deposits := make(chan productDeposit,20)
	purchases := make(chan purchase,20)
	jobListChannel := make(chan stateRequest)
	warehouseChannel := make(chan stateRequest)
	reportChannel := make(chan int, 25)
	aChans := make([]chan *jobAssignment,AdditionMachines)
	mChans := make([]chan *jobAssignment,MultiplicationMachines)
	maintenanceChans := make([]chan responseRequest,AdditionMachines+MultiplicationMachines)
	jobCounts := make([]int,Workers)
	patients := make([]bool,Workers)
	rand.Seed(time.Now().UnixNano())
	for i := range aChans {
		aChans[i] = make(chan *jobAssignment)
		maintenanceChans[i] = make(chan responseRequest)
	}
	for i := range mChans {
		mChans[i] = make(chan *jobAssignment)
		maintenanceChans[AdditionMachines+i] = make(chan responseRequest)
	}
	go jobList(jobAssignments,jobRequests,jobListChannel)
	go warehouse(deposits,purchases,warehouseChannel)
	go maintenance(reportChannel,maintenanceChans)
	for i := range aChans {
		go additionMachine(i,aChans[i],maintenanceChans[i])
	}
	for i := range mChans {
		go multiplicationMachine(i,mChans[i],maintenanceChans[AdditionMachines+i])
	}
	for i:=1;i<=Workers;i++{
		go worker(i,jobRequests,deposits,aChans,mChans,jobCounts,patients,reportChannel)
	}
	go client(purchases)
	if !LoudMode {
		go calmMode(jobListChannel,warehouseChannel,jobCounts,patients)
	}
	boss(jobAssignments)
}
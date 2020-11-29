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
	result int
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

func additionMachine(id int, jaChannel <-chan *jobAssignment){
	for{
		currJob := <-jaChannel
		time.Sleep(MachineWorkTime)
		currJob.newJob.result = currJob.newJob.firstArg + currJob.newJob.secondArg
		currJob.response <- true
	}
}

func multiplicationMachine(id int, jaChannel <-chan *jobAssignment){
	for{
		currJob := <-jaChannel
		time.Sleep(MachineWorkTime)
		currJob.newJob.result = currJob.newJob.firstArg * currJob.newJob.secondArg
		currJob.response <- true
	}
}

func worker(id int, jobRequests chan<- jobRequest,depoosits chan<- productDeposit, aQueues []chan *jobAssignment, mQueues []chan *jobAssignment, jobCounts []int, patient []bool) {
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
			if patient[id-1] {
				aQueues[rand.Int()%AdditionMachines] <- &ja
			} else {
				waiting := true
				for waiting {
					randQueue := rand.Int()%AdditionMachines
					select {
					case aQueues[randQueue] <- &ja:
						waiting = false
					case <-time.After(ImpatientInterval):
					}
				}
			}
			<-ja.response
			d := productDeposit{
				product: ja.newJob.result,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
		case "*":
			if patient[id-1] {
				mQueues[rand.Int()%MultiplicationMachines] <- &ja
			} else {
				waiting := true
				for waiting {
					randQueue := rand.Int()%MultiplicationMachines
					select {
					case mQueues[randQueue] <- &ja:
						waiting = false
					case <-time.After(ImpatientInterval):
					}
				}
			}
			<-ja.response
			d := productDeposit{
				product: ja.newJob.result,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
		default:
			panic("wrong operand")
		}
		jobCounts[id-1]++
		loudPrint("Worker " + strconv.Itoa(id) + ": " + strconv.Itoa(ja.newJob.firstArg) + ja.newJob.operand + strconv.Itoa(ja.newJob.secondArg) + " = " + strconv.Itoa(ja.newJob.result))
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
	aChans := make([]chan *jobAssignment,AdditionMachines)
	mChans := make([]chan *jobAssignment,MultiplicationMachines)
	jobCounts := make([]int,Workers)
	patients := make([]bool,Workers)
	rand.Seed(time.Now().UnixNano())
	for i := range aChans {
		aChans[i] = make(chan *jobAssignment)
	}
	for i := range mChans {
		mChans[i] = make(chan *jobAssignment)
	}
	go jobList(jobAssignments,jobRequests,jobListChannel)
	go warehouse(deposits,purchases,warehouseChannel)
	for i := range aChans {
		go additionMachine(i,aChans[i])
	}
	for i := range mChans {
		go multiplicationMachine(i,mChans[i])
	}
	for i:=1;i<=Workers;i++{
		go worker(i,jobRequests,deposits,aChans,mChans,jobCounts,patients)
	}
	go client(purchases)
	if !LoudMode {
		go calmMode(jobListChannel,warehouseChannel,jobCounts,patients)
	}
	boss(jobAssignments)
}
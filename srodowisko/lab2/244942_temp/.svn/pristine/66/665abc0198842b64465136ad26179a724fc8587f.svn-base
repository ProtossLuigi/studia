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

func loudPrint(str string){
	if LoudMode {
		fmt.Println(str)
	}
}

func boss(jobAssignments chan<- jobAssignment){
	operands := [3]string{"+","-","*"}
	for{
		var newJobAssignment jobAssignment
		newJobAssignment.newJob.firstArg = rand.Int()%1024
		newJobAssignment.newJob.secondArg = rand.Int()%1024
		newJobAssignment.newJob.operand = operands[rand.Int()%3]
		newJobAssignment.response = make(chan bool)
		jobAssignments <- newJobAssignment
		<-newJobAssignment.response
		loudPrint("Boss: " + strconv.Itoa(newJobAssignment.newJob.firstArg) + " " + newJobAssignment.newJob.operand + " " + strconv.Itoa(newJobAssignment.newJob.secondArg))
		time.Sleep(time.Duration(BossSleep - BossVariance + 2*rand.Float64()*BossVariance) * time.Second)
	}
}

func jobList(jobAssignments <-chan jobAssignment, jobRequests <-chan jobRequest, stateRequests <-chan stateRequest){
	jobs := list.New()
	for{
		switch jobs.Len(){
		case 0:
			select{
			case sr := <-stateRequests:
				var s string
				j := jobs.Front()
				for j != nil{
					s = s + strconv.Itoa(j.Value.(job).firstArg) + " " + j.Value.(job).operand + " " + strconv.Itoa(j.Value.(job).secondArg) + "\n"
					j = j.Next()
				}
				sr.response <- s
			case jobAssignment := <-jobAssignments:
				jobs.PushBack(jobAssignment.newJob)
				jobAssignment.response <- true
			}
		case MaxJobs:
			select{
			case sr := <-stateRequests:
				var s string
				j := jobs.Front()
				for j != nil{
					s = s + strconv.Itoa(j.Value.(job).firstArg) + " " + j.Value.(job).operand + " " + strconv.Itoa(j.Value.(job).secondArg) + "\n"
					j = j.Next()
				}
				sr.response <- s
			case jobRequest := <-jobRequests:
				jobRequest.response <- jobs.Front().Value.(job)
				jobs.Remove(jobs.Front())
			}
		default:
			select {
			case sr := <-stateRequests:
				var s string
				j := jobs.Front()
				for j != nil{
					s = s + strconv.Itoa(j.Value.(job).firstArg) + " " + j.Value.(job).operand + " " + strconv.Itoa(j.Value.(job).secondArg) + "\n"
					j = j.Next()
				}
				sr.response <- s
			case jobAssignment := <-jobAssignments :
				jobs.PushBack(jobAssignment.newJob)
				jobAssignment.response <- true
			case jobRequest := <-jobRequests :
				jobRequest.response <- jobs.Front().Value.(job)
				jobs.Remove(jobs.Front())
			}
		}
	}
}



func worker(id int, jobRequests chan<- jobRequest,depoosits chan<- productDeposit) {
	for {
		req := jobRequest{response: make(chan job)}
		jobRequests <- req
		j := <-req.response
		switch j.operand {
		case "+":
			d := productDeposit{
				product: j.firstArg + j.secondArg,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
			loudPrint("Worker " + strconv.Itoa(id) + ": " + strconv.Itoa(j.firstArg) + " + " + strconv.Itoa(j.secondArg) + " = " + strconv.Itoa(d.product))
		case "-":
			d := productDeposit{
				product: j.firstArg - j.secondArg,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
			loudPrint("Worker " + strconv.Itoa(id) + ": " + strconv.Itoa(j.firstArg) + " - " + strconv.Itoa(j.secondArg) + " = " + strconv.Itoa(d.product))
		case "*":
			d := productDeposit{
				product: j.firstArg * j.secondArg,
				response: make(chan bool)}
			depoosits <- d
			<-d.response
			loudPrint("Worker " + strconv.Itoa(id) + ": " + strconv.Itoa(j.firstArg) + " * " + strconv.Itoa(j.secondArg) + " = " + strconv.Itoa(d.product))
		default:
			panic("wrong operand")
		}
		time.Sleep(time.Duration(WorkerSleep - WorkerVariance + 2*rand.Float64()*WorkerVariance) * time.Second)
	}
}

func warehouse(deposits <-chan productDeposit, purchases <-chan purchase, stateRequests <-chan stateRequest){
	products := list.New()
	for{
		switch products.Len(){
		case 0:
			select {
			case sr := <-stateRequests:
				var s string
				p := products.Front()
				for p != nil{
					s = s + strconv.Itoa(p.Value.(int)) + "\n"
					p = p.Next()
				}
				sr.response <- s
			case d := <-deposits:
				products.PushBack(d.product)
				d.response <- true
			}
		case WarehouseThreshold:
			select {
			case sr := <-stateRequests:
				var s string
				p := products.Front()
				for p != nil{
					s = s + strconv.Itoa(p.Value.(int)) + "\n"
					p = p.Next()
				}
				sr.response <- s
			case p := <-purchases :
				toSell := products.Front()
				cap := rand.Int()%products.Len()
				for i := 0; i < cap; i++{
					toSell = toSell.Next()
				}
				p.response <- toSell.Value.(int)
				products.Remove(toSell)
			}
		default:
			select {
			case sr := <-stateRequests:
				var s string
				p := products.Front()
				for p != nil{
					s = s + strconv.Itoa(p.Value.(int)) + "\n"
					p = p.Next()
				}
				sr.response <- s
			case d := <-deposits :
				products.PushBack(d.product)
				d.response <- true
			case p := <-purchases :
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

func calmMode(jobListChannel chan<- stateRequest, warehouseChannel chan<- stateRequest){
	var input string
	for {
		fmt.Scan(&input)
		switch input {
		case "jobs":
			req := stateRequest{response:make(chan string)}
			jobListChannel <- req
			fmt.Printf(<-req.response)
		case "products":
			req := stateRequest{response:make(chan string)}
			warehouseChannel <- req
			fmt.Printf(<-req.response)
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
	rand.Seed(time.Now().UnixNano())
	go jobList(jobAssignments,jobRequests,jobListChannel)
	go warehouse(deposits,purchases,warehouseChannel)
	for i:=1;i<=Workers;i++{
		go worker(i,jobRequests,deposits)
	}
	go client(purchases)
	if !LoudMode {
		go calmMode(jobListChannel,warehouseChannel)
	}
	boss(jobAssignments)
}
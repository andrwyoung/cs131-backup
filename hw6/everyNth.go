package main

import "fmt"
import "container/list"

// assume n is nonzero
func everyNth(l *list.List, n int) *list.List {
	result := list.New()
	counter := 0

	for i := l.Front(); i != nil; i = i.Next() {
		counter++
		if counter % n == 0 {
			result.PushBack(i.Value)
		}
	}

	return result
}

func initList(l *list.List, n int) {
	for i := 0; i < n; i++ {
		l.PushBack(i)
	}
}

func printList(l *list.List) {
	for i := l.Front(); i != nil; i = i.Next() {
		fmt.Println(i.Value)
	}
}

func main() {
	my_list := list.New()
	initList(my_list, 1000)
	res_list := everyNth(my_list, 109)
	printList(res_list)
}

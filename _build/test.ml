let rec contains e s = match s with
| [] -> false
| h::t -> if h = e then true
		  else (contains e t);;

contains [1] [];;

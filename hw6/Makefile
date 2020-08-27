default:
	go build everyNth.go

.PHONY: check
check: default
	./everyNth > ans2.txt && \
	if cmp -s "ans2.txt" "ans.txt"; then \
		rm ans2.txt; \
		echo "make check PASSED"; \
        exit 0; \
    else \
		rm ans2.txt; \
		echo "make check FAILED"; \
		exit 1; \
	fi 

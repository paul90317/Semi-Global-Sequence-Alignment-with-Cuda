%.cue:%.cu
	nvcc -I ../src/headers $< -o ./out/$*
	./out/$*
%.cppe:%.cpp
	g++ -I ../src/headers $< -o ./out/$*
	./out/$*
cl:
	rm -rf ./out/*
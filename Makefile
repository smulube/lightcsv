all:
	ruby ./setup.rb config
	ruby ./setup.rb setup

install:
	ruby ./setup.rb install

clean:
	ruby ./setup.rb clean

test: test_
test_:
	ruby -w ./setup.rb test

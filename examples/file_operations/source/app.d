import vibe.core.core;
import vibe.core.file;
import std.stdio;

static if (__VERSION__ >= 2076)
	import std.datetime.stopwatch;
else
	import std.datetime;

auto peekMSecs(T)(T sw) {
	static if (__VERSION__ >= 2076)
		return sw.peek.total!"msecs";
	else
		return sw.peek.msecs;
}

void main() {
	FileStream fs = openFile("./hello.txt", FileMode.createTrunc);
	StopWatch sw;
	sw.start();
	bool finished;
	auto task = runTask({
		writeln("Task 1: Starting write operations to hello.txt");
		while (sw.peekMSecs < 150) {
			fs.write("Some string is being written here ..");
		}
		writeln("Task 1: Final offset: ", fs.tell(), "B, file size: ",
			fs.size(), "B", ", total time: ", sw.peekMSecs, " ms");
		fs.close();
		finished = true;
	});

	runTask({
		while (!finished) {
			writeln("Task 2: Task 1 has written ", fs.size(), "B so far in ", sw.peekMSecs, " ms");
			sleep(10.msecs);
		}
		removeFile("./hello.txt");
		writeln("Task 2: Done.");
		sw.stop();
		exitEventLoop();
	});
	writeln("Main Thread: Writing small chunks in a yielding task (Task 1) for 150 ms");

	runApplication();
}
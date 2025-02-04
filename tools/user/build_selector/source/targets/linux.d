module targets.linux;
import commons;

void prepareLinux(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!std.file.exists("/usr/include/GL/gl.h"))
	{
		t.writelnError("/usr/include/GL/gl.h wasn't found in your system. This is required for the OpenGL implementation.");
		t.writelnHighlighted("\t The following command will be executed to install it: sudo apt-get install libgl1-mesa-dev");
		t.flush;
		wait(spawnShell("sudo apt-get install libgl1-mesa-dev"));
	}
	auto pid = spawnShell("cd ../../../ && dub" ~ cOpts.getDubOptions);
	wait(pid);
}

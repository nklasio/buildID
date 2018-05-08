import std.getopt;
import std.stdio;
import core.Parser;
int main(string[] args)
{
	string buildFile = "";

    auto helpInformation = getopt(args, "b|buildfile", "Specify buildfile", &buildFile);

    if(helpInformation.helpWanted) {
        defaultGetoptPrinter("buildID - Copyright © 2018, Niklas Stambor", helpInformation.options);
		writeln("Default buildfile: <project-root>build.bid");
    }
	Parser parser = new Parser(buildFile != null ? buildFile : "build.bid");
	parser.parse();
	return 0;
}


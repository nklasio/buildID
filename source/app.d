import std.stdio;
import core.Parser;
void main()
{
	Parser parser = new Parser("build.bid");
	parser.parse();
}

module core.Parser;

import std.json;
import std.file;
import std.stdio;
import std.string;
import std.array;
import std.conv;
import core.models.Project;
import core.models.SourceDirectory;
import core.models.Command;
import core.VariableManager;

///
/// dmd -c -O -od=build-test -release source/app.d source/core/Parser.d source/core/models/Project.d source/core/models/Command.d source/core/models/SourceDirectory.d
///


class Parser {
    private string _buildFile = void;
    private Project _project = void;
    private string[string] _variables = void;
    private SourceDirectory[] _sourceDirectorys = void;
    private bool[string] _dependencies = void;
    private Command[] _prepareCommands = void;
    private Command[] _buildCommands = void;
    private Command[] _checkCommands = void;


    this(string buildFile) {
        assert(exists(buildFile) == true, "Build file does not exist!");
        this._buildFile = buildFile;
    }

    int parse() {
        string buildFileContent = readText(_buildFile);
        auto parsedBuildFile = parseJSON(buildFileContent);
        
        _project = 
            Project(parsedBuildFile["project"]["name"].str,
                parsedBuildFile["project"]["author"].str,
                parsedBuildFile["project"]["license"].str);

        foreach(var; parsedBuildFile["variables"].array) {
            _variables[var["name"].str] = var["value"].str;
        }

        foreach(dir; parsedBuildFile["sourceDirs"].array) {
            _sourceDirectorys ~= new SourceDirectory(dir["path"].str, dir["recursive"].type == JSON_TYPE.TRUE);
        }

        foreach(dep; parsedBuildFile["dependencies"].array) {
            _dependencies[dep["lib"].str] = dep["buildRequirement"].type == JSON_TYPE.TRUE;
        }
        
        VariableManager.init(_variables, _sourceDirectorys);

        auto functionContent = parsedBuildFile["functions"];

        foreach(prep; functionContent["prepare"].array) {
            string[] reqs = [];
            foreach(req; prep["requirements"].array) { reqs ~= req.str;}
            _prepareCommands ~= new Command(prep["command"].str, reqs);
        }

        foreach(build; functionContent["build"].array) {
            string[] reqs = [];
            foreach(req; build["requirements"].array) { reqs ~= req.str;}
            _buildCommands ~= new Command(build["command"].str, reqs);
        }

        foreach(check; functionContent["prepare"].array) {
            string[] reqs = [];
            foreach(req; check["requirements"].array) { reqs ~= req.str;}
            _checkCommands ~= new Command(check["command"].str, reqs);
        }

        debug {
            writeln("Project: ", _project);
            writeln("Variables: ", _variables);
            writeln("SourceDirectorys: ", _sourceDirectorys.length);
            writeln("Dependencies: ", _dependencies);

            writeln("Parsing functions...");
            writeln("PrepareCommands: ", _prepareCommands.length);
            writeln("BuildCommands: ", _buildCommands.length);
            writeln("CheckCommands: ", _checkCommands.length);
        }

        writeln("Executin functions...");
        foreach(pFunc; _prepareCommands) {
            pFunc.execute();
        }
        foreach(bFunc; _buildCommands) {
            bFunc.execute();
        }
        foreach(cFunc; _checkCommands) {
            cFunc.execute();
        }
        return -1;
    }

}
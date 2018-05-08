module core.models.Command;

import std.algorithm.searching;
import std.stdio;
import std.string;
import std.regex;
import std.process;
import std.conv;
import core.VariableManager;

class Command  {
    string _command = void;
    string[] _requirements = void;

    this(string command, string[] requirements = []) {
        this._command = command;
        this._requirements = requirements;

         
    }

    bool execute() {
        resolveSymbols();      
        auto proc = executeShell(_command);
        if(proc.status != 0) {
            writeln(proc.output);
            writeln(_command);
            writeln("ERROR! : Program returned " ~ to!string(proc.status));
            return false;
        } else {
            return true;
        }       
    }

    bool resolveSymbols() {
        if(_command.canFind("$(")) {
            string resolvedCommand = "";
            foreach(res ;_command.matchAll("\\$\\((.*?)\\)")) {
                if(res[1].canFind(":")) {
                    resolvedCommand = _command.replace(res[0], VariableManager.ResolveSource(res[1]));
                } else {
                    resolvedCommand = _command.replace(res[0], VariableManager.Variables[res[1]]);
                }
            }
            if(resolvedCommand.empty) {
                resolvedCommand = _command;
            } else {
                _command = resolvedCommand;
            }
            resolveSymbols();
        } else {
            return true;
        }
        return false;
    }
}
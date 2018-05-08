module core.VariableManager;

import core.models.SourceDirectory;
import std.array;
import std.stdio;
import std.string;
struct VariableManager {
    static string[string] Variables = void;
    static SourceDirectory[] SourceDirectorys = [];
    static void init(string[string] variables, SourceDirectory[] sourceDirs = []) {
        VariableManager.Variables = variables;
        VariableManager.SourceDirectorys = sourceDirs;
    }

    static string ResolveSource(string pattern) {
        string[] entries = [];
        foreach(source; VariableManager.SourceDirectorys) {
            entries ~= source.fetchEntries(format("*.%s", pattern));
        }
        return entries.join(" ");
    }

}
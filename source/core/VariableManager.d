module core.VariableManager;

import core.models.SourceDirectory;
import std.array;
import std.stdio;
import std.string;
import std.regex;
import std.algorithm.searching;

struct VariableManager {
    static string[string] Variables = void;
    static SourceDirectory[] SourceDirectorys = [];
    static void init(string[string] variables, SourceDirectory[] sourceDirs = []) {
        VariableManager.Variables = variables;
        VariableManager.SourceDirectorys = sourceDirs;
    }

    static string ResolveSource(string pattern) {
        auto pa = pattern.split(":");
        if(pa[0].canFind("source")) {
            string[] entries = [];
            foreach(source; VariableManager.SourceDirectorys) {
                entries ~= source.fetchEntries(format("*.%s", pa[1]));
            }
            return entries.join(" ");
        } else {
            writeln(pa, " | ", __LINE__);
            string[] entries = [];
            auto build = new SourceDirectory(VariableManager.Resolve(VariableManager.Variables[pa[0]]), false, true);
            entries ~= build.fetchEntries(format("*.%s", pa[1]));
            return entries.join(" ");
        }
    }

    static string Resolve(string s) {
        writeln(s);
        if(s.canFind("$(")) {
            string resolved = "";
            foreach(res ;s.matchAll("\\$\\((.*?)\\)")) {
                writeln(res);
                if(res[1].canFind(":")) {
                    resolved = s.replace(res[0], VariableManager.ResolveSource(res[1]));
                } else {
                    resolved = s.replace(res[0], VariableManager.Variables[res[1]]);
                }
            }
            if(resolved.empty) {
                resolved = s;
            } else {
                s = resolved;
            }
            VariableManager.Resolve(s);
        } else {
            return s;
        }
        return s;
    }

}
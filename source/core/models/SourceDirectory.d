module core.models.SourceDirectory;

import std.file;
import std.stdio;

class SourceDirectory {
    private string _path = void;
    private bool _recursive = false;
    private string[] _entries = void;

    import std.format;
    this(string path, bool recursive) {
        assert(exists(path) == true, format("Source Path is not valid \"%s\"", path));
        this._path = path;
        this._recursive = recursive;
        fetchEntries();
    }

    string[] fetchEntries(string pattern) {
        string[] entries;
        foreach(entry; dirEntries(_path, pattern,_recursive ? SpanMode.depth: SpanMode.shallow, false)) {
            if(attrIsFile(getAttributes(entry)))
                entries ~= entry;
        }
        return entries;
    }

    private void fetchEntries() {
        foreach(entry; dirEntries(_path, _recursive ? SpanMode.depth: SpanMode.shallow, false)) {
            if(attrIsFile(getAttributes(entry)))
                _entries ~= entry;
        }
    }

    @property string[] getEntries() {
        return _entries;
    }
}
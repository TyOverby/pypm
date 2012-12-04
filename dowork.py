#!/bin/env python
import sys
import subprocess
import pprint

def run_script(script, *args):
    proc = subprocess.Popen(['bash', script]+list(args),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        stdin=subprocess.PIPE,universal_newlines=True)
    stdout, stderr = proc.communicate()
    return proc.returncode, stdout, stderr


def install(name):
    code, out, err = run_script("install.sh", name)
    if code != 0:
        print "Could not install {}".format(name)
        print out
        print err
        return False
    return True

def has(package, executable="*"*400, clean=""):
    #print "has " + package + "~~" + executable
    code, out, err = run_script("has.sh", package, executable, clean)
    if code != 0:
        return False
    return True

def search(name):
    code, out, err = run_script("search.sh", name)
    return "\n".join(out.split("\n"))

def mark(name):
    run_script("mark.sh", name)


def rewrite(name):
    return name.replace("(",".").replace(")","")

def dependencies(name):
    code, out, err = run_script("deps.sh", name)
    if code == 0:
        m = {}
        lines = [x.strip() for x in out.split("\n")]

        last = ""
        for line in lines:
            if len(line)>0:
                if line.startswith("dependency"):
                    last = rewrite(line.split(" ")[1])
                    m[last] = []
                else:
                    m[last].append(rewrite(line.split(" ")[1]))
        return m

    return {}

def do_install(name, tabs=0, clean=""):
    if "i686" in name:
        return False

    print "\t"*tabs + "Installing {}".format(name)
    mark(name)

    deps = dependencies(name)
    for dep in deps:
        filled = False
        for provider in deps[dep]:
            if has(provider, dep, clean):
                filled = True
                print "\t"*(tabs+1) + "Met dependency {}".format(dep)
                break

        if not filled:
            print "\t"*(tabs+1) + "Unmet dependency {}".format(dep)
            for provider in deps[dep]:
                if do_install(provider, tabs+2, clean):
                    break

    print "\t"*(tabs+1) + "Downloading {}".format(name)
    return install(name)

if __name__ == "__main__":
    command = sys.argv[1]

    if command == "install":
        if sys.argv[2] == "--clean":
            for name in sys.argv[3::]:
                do_install(name,clean="yes")
        else:
            for name in sys.argv[2::]:
                do_install(name)
    elif command == "search":
        for name in sys.argv[2::]:
            search(name)
    elif command == "deps":
        for name in sys.argv[2::]:
            pprint.pprint(dependencies(name))
    else:
        print "no command found.  read the source"





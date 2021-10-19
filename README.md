# Blirb Simulation
![Screenshot](screenshot.png?raw=true)
A simple Processing sketch to represent flocking and hunting behavior in bird-like AI

## Description

This project was intended to be practice and for me to learn about Processing. It also was an exercise in learning how to program simple AI behaviors.

## Getting Started

### Running in PDE

This project is able to run in PDE without any changes. It will run the simulation with the given default number of blirbs.

### Running from the Command Line

You can utilize the Processing CLI to run this program as well.

```
processing-java.exe --sketch={PATH_TO_BLIRBS_SIM_FOLDER} --run
```

The CLI also allows for a single argument: a fully qualified path name to a text file. This text file can be used to spawn any number of blirbs with any number of name prefixes. See [blirblist-demo.txt](blirblist-demo.txt) for an example on this.

```
processing-java.exe --sketch={PATH_TO_BLIRBS_SIM_FOLDER} --run blirblist-demo.txt
```

## Authors

[@maikotui](https://twitter.com/maikotui)

## Version History

* 1.0
    * Initial Release
    * Basic bird behaviour
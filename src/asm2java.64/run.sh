#!/bin/bash

java -Xcheck:jni -Djava.library.path=$(pwd) -cp . HelloWorld


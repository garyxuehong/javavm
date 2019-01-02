#!/bin/bash

echo ">>gen code..."

echo '
public class Foo {
 public static void main(String[] args) {
  boolean flag = true;
  if (flag) System.out.println("Hello, Java!");
  if (flag == true) System.out.println("Hello, JVM!");
 }
}' > Foo.java


echo ">>javac Foo.java"
javac Foo.java

echo ">>Run unmoded class"
java Foo

echo ">>Read class file with asmtools"
java -cp ~/install/asmtools.jar org.openjdk.asmtools.jdis.Main Foo.class > Foo.jasm.1

echo ">>Print it out"
cat Foo.jasm.1

echo ">>Awk replce generated jasm file for boolean flag to value 3"
awk 'NR==1,/iconst_1/{sub(/iconst_1/, "iconst_3")} 1' Foo.jasm.1 > Foo.jasm

echo ">>Print moded jasm file"
cat Foo.jasm

echo ">>Print diff"
diff --unified=3 Foo.jasm.1 Foo.jasm

echo ">>Use asmtools to compile mod jasm file"
java -cp ~/install/asmtools.jar org.openjdk.asmtools.jasm.Main Foo.jasm

echo ">>Run mod class, expected 3 will be stored as 1, which is value of true"
java Foo

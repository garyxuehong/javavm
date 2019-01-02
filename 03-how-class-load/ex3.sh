#!/bin/bash

echo "Generating Singleton.java"
echo '
public class Singleton {
  private Singleton() {}
  private static class LazyHolder {
    static final Singleton INSTANCE = new Singleton();
    static {
      System.out.println("LazyHolder.<clinit>");
    }
  }
  public static Object getInstance(boolean flag) {
    if (flag) return new LazyHolder[2];
    return LazyHolder.INSTANCE;
  }
  public static void main(String[] args) {
    getInstance(true);
    System.out.println("----");
    getInstance(false);
  }
}' > Singleton.java

echo "Compiling..."
javac Singleton.java

echo "Run with class loading order printed"
java -verbose:class Singleton

echo "Reading LazyHolder"
java -cp ~/install/asmtools.jar org.openjdk.asmtools.jdis.Main Singleton\$LazyHolder.class > Singleton\$LazyHolder.jasm.1

echo "Mod stack?"
awk 'NR==1,/stack 1/{sub(/stack 1/, "stack 0")} 1' Singleton\$LazyHolder.jasm.1 > Singleton\$LazyHolder.jasm

echo "Put back moded jasm"
java -cp ~/install/asmtools.jar org.openjdk.asmtools.jasm.Main Singleton\$LazyHolder.jasm

echo "Run with new result"
java -verbose:class Singleton


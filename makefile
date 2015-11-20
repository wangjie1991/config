在一个makefile中输出一个程序的debug版本和release版本

场景：
开发人员（rd）和测试人员（qa）是不同的人，可执行程序是通过配置管理平台提供的。同时，所有程序要上线运行，要通过qa的测试，然后将测试通过的程序，在配置管理平台上输出后上线。（从百度的流程中提取出来的，其他公司的流程未知）

需求：
debug版本的会有一些额外的处理，以及能够打印更多的log；release版本的，需要关闭可能影响性能的一些处理，以及关闭过多的log打印。 rd在送测时，希望，同时送测两个版本的可执行程序，一方面方便qa在需要更详细日志的时候，可以使用debug版本。另一方面，rd不需要单独编译 debug版本给qa使用。

一些知识：
gcc/g++中，有若干参数跟debug有关系，具体的可以看gcc/g++的man页，或者本文后面附录部分。
1、-g参数，在编译中添加一些调试信息，gdb可以使用这些信息。
2、-D参数和-U参数，-D将宏定义传递给程序，-U取消程序中的宏定义。

程序开发：
通过宏定义（比如_DEBUG_）对一些功能或者日志进行开关控制，比如将中间状态存储到文件中，供分析用等。

makefile：
1、makefile中，对一个.o文件只会编译一次，但经测试，同一个c或者cpp文件可以编译为多个不同的.o文件。
2、-g参数和-D、-U参数是在编译成.o文件时生效的。
3、故，对与debug版本和release版本的，可以生成不同的两份.o文件。
4、在link阶段，对debug和release两个版本的程序，使用各自那份的.o文件。

一个例子：
有三个文件，main.cpp, work.cpp, work.h
makefile：
obj1=main.o work.o
obj2=main.debug.o work.debug.o
target1= app
target2= app_for_debug

all: $(target1) $(target2)
clean: rm -f $(obj1) $(obj2) $(target1) $(target2)
%.o : %.cpp
g++ -c $< -o $@ 
%.debug.o : %.cpp
g++ -D_DEBUG_ -c $< -o $@
$(target1):$(obj1)
g++ -o $(target1) $@ $^
$(target2):$(obj2)
g++ -g -o $(target2) $@ $^

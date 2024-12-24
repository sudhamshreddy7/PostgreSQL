README:

Project 1. Getting Started with PostgreSQL
Your goal in this assignment is to install PostgreSQL, start up a PostgreSQL server, define some tables, and try out some simple queries using SQL.
Installation of PostgreSQL
You are required to compile the PostgreSQL source code and install the executables, header files, and libraries. It is your responsibility to figure out how to set up your environment to compile and install the system. Installing open-source software from source can be a painful experience, but it is a necessary part of graduate training in the computer science field. If you have never done so, it is time now. PostgreSQL supports a wide variety of OSs and should be relatively easy to install. Therefore, I will not provide detailed instructions on the installation process except the following two points:
1.	Download a copy of PostgreSQL source from the following URL: https://www.postgresql.org/ftp/source/v14.9/Links to an external site..
2.	Read the PostgreSQL documentation from https://www.postgresql.org/docs/14/index.htmlLinks to an external site.  to an external site.for help about installation. You may start from Section I.1 "Getting Started" and then focus on Section III.17 "Installation from Source Code". 
 
Testing PostgreSQL
Sections 19.1 to 19.3 of the PostgreSQL documentation shows the steps on how to start a PostgreSQL server and create a database. Follow those commands to build your own database. Upon successful installation of the system, an SQL client named 'psql' will be provided. Now you can use this client program to create your own database tables using SQL. You are required to complete the following tasks:
1.	Create at least two tables using "create table ..." in SQL and load some data into those tables.
2.	Write at least two "select ... from ..." statements to query the database.



Code changed in files to use LRU as page replacement:
1.	src/backend/storage/buffer/freelist.c
2.	src/backend/storage/buffer/bufmgr.c
3.	src/backend/storage/buffer/buf_init.c
4.	src/include/storage/buf_internals.h


Changes in buf_internals.h:
•	Added a new attribute “timestamp” to track when the buffer is used
Changes in buf_init.c:
•	In InitBufferPool function initializing timestamp value of each buffer to 0
Changed in bufmgr.c:
•	Declared a new function getMaxTimeStamp1  which returns the maximum time stamp of all buffers to update the recently used buffer’s timestamp to 1+maximum
•	In ReadBuffer_common function if the buffer is found in buffer pool the we update the buffer’s timestamp to maximum timestamp+1 and print the buffer id
Changes in freelist.c:
•	Declared a new function getMaxTimeStamp which returns the maximum time stamp of all buffers to update the recently used buffer’s timestamp to 1+maximum
•	Changes made in StrategyGetBuffer:
1.	The LRU implementation is from line number :332.
2.	To Iterate the buffer pool(NBuffers time) and fetch the least recently used buffer,update its time stamp and return the buffer.

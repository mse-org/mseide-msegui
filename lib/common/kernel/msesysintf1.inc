{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

function sys_mutexcreate(out mutex: mutexty): syserrorty;
function sys_mutexdestroy(var mutex: mutexty): syserrorty;
function sys_mutexlock(var mutex: mutexty): syserrorty;
function sys_mutextrylock(var mutex: mutexty): syserrorty;
  //sye_ok if calling thread has lock, sye_busy if already locked by other thread
function sys_mutexunlock(var mutex: mutexty): syserrorty;

function sys_semcreate(out sem: semty; count: integer): syserrorty;
function sys_semdestroy(var sem: semty): syserrorty;
//function sys_semreset(var sem: semty): syserrorty; //call from single thread!
function sys_sempost(var sem: semty): syserrorty;
function sys_semwait(var sem: semty;  timeoutusec: integer): syserrorty;
          //timeoutusec <= 0 -> no timeout
          //sye_ok -> semaphore signaled
          //sye_timeout -> timeout
          //sye_semaphore -> error
function sys_semtrywait(var sem: semty): boolean;
function sys_semcount(var sem: semty): integer;

function sys_condcreate(out cond: condty): syserrorty;
function sys_conddestroy(var cond: condty): syserrorty;
function sys_condlock(var cond: condty): syserrorty;
function sys_condunlock(var cond: condty): syserrorty;
function sys_condsignal(var cond: condty): syserrorty;
function sys_condbroadcast(var cond: condty): syserrorty;
function sys_condwait(var cond: condty; timeoutusec: integer): syserrorty;
          //timeoutusec = 0 -> no timeout
          //sye_ok -> condition signaled
          //sye_timeout -> timeout
          //sye_cond -> error

function sys_utctolocaltime(const value: tdatetime): tdatetime;
function sys_localtimetoutc(const value: tdatetime): tdatetime;



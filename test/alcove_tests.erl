%%% Copyright (c) 2014, Michael Santos <michael.santos@gmail.com>
%%%
%%% Permission to use, copy, modify, and/or distribute this software for any
%%% purpose with or without fee is hereby granted, provided that the above
%%% copyright notice and this permission notice appear in all copies.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-module(alcove_tests).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").
-include_lib("kernel/include/file.hrl").
-include_lib("alcove/include/alcove.hrl").

alcove_test_() ->
    {setup,
        fun start/0,
        fun stop/1,
        fun run/1
    }.

run(State) ->
    % Test order must be maintained
    [
        version(State),
        pid(State),
        getpid(State),
        sethostname(State),
        setns(State),
        unshare(State),
        mount(State),
        tmpfs(State),
        chroot(State),
        chdir(State),
        setrlimit(State),
        setgid(State),
        setuid(State),
        fork(State),
        signal(State),
        prctl(State),
        execvp(State),
        stdout(State),
        stderr(State)
    ].

start() ->
    Port = alcove_drv:start([{exec, "sudo"}]),
    case os:type() of
        {unix,linux} = OS ->
            Flags = alcove:define(Port, clone, [
                    newipc,
                    newnet,
                    newns,
                    newpid,
                    newuts
                ]),
            {ok, Child} = alcove:clone(Port, Flags),
            {OS, Port, Child};
        {unix,_} = OS ->
            {ok, Child} = alcove:fork(Port),
            {OS, Port, Child}
    end.

stop({_, Port, _Child}) ->
    alcove_drv:stop(Port).

version({_, Port, _Child}) ->
    Version = alcove:version(Port),
    ?_assertEqual(true, is_binary(Version)).

pid({_, Port, _Child}) ->
    Pids = alcove:pid(Port),
    ?_assertEqual(1, length(Pids)).

getpid({{unix,linux}, Port, Child}) ->
    % Running in a PID namespace
    PID = alcove:getpid(Port, [Child]),
    ?_assertEqual(1, PID);
getpid({_, Port, Child}) ->
    PID = alcove:getpid(Port, [Child]),
    ?_assertEqual(true, PID > 0).

sethostname({{unix,linux}, Port, Child}) ->
    Reply = alcove:sethostname(Port, [Child], "alcove"),
    Hostname = alcove:gethostname(Port, [Child]),
    [?_assertEqual(ok, Reply),
        ?_assertEqual({ok, <<"alcove">>}, Hostname)];
sethostname({_, Port, Child}) ->
    Hostname = alcove:gethostname(Port, [Child]),
    ?_assertMatch({ok, <<_/binary>>}, Hostname).

setns({{unix,linux}, Port, Child}) ->
    {ok, Child1} = alcove:fork(Port),
    ok = alcove:setns(Port, [Child1], [
            "/proc/",
            integer_to_list(Child),
            "/ns/uts"
        ]),
    Hostname0 = alcove:gethostname(Port, [Child]),
    Hostname1 = alcove:gethostname(Port, [Child1]),
    ?_assertEqual(Hostname0, Hostname1);
setns({_, _Port, _Child}) ->
    ?_assertEqual(ok,ok).

unshare({{unix,linux}, Port, _Child}) ->
    {ok, Child1} = alcove:fork(Port),
    ok = alcove:unshare(Port, [Child1], alcove:clone_define(Port, newuts)),
    Reply = alcove:sethostname(Port, [Child1], "unshare"),
    Hostname = alcove:gethostname(Port, [Child1]),
    [?_assertEqual(ok, Reply),
        ?_assertEqual({ok, <<"unshare">>}, Hostname)];
unshare({_, _Port, _Child}) ->
    ?_assertEqual(ok,ok).

mount({{unix,linux}, Port, Child}) ->
    Flags = alcove:define(Port, mount, [bind,rdonly,noexec]),
    Mount = alcove:mount(Port, [Child], "/tmp", "/mnt", "", Flags, ""),
    Umount = alcove:umount(Port, [Child], "/mnt"),
    [
        ?_assertEqual(ok, Mount),
        ?_assertEqual(ok, Umount)
    ];
mount({_, _Port, _Child}) ->
    ?_assertEqual(ok,ok).

tmpfs({{unix,linux}, Port, Child}) ->
    Flags = alcove:define(Port, mount, [noexec]),
    Mount = alcove:mount(Port, [Child], "tmpfs", "/mnt", "tmpfs", Flags, <<"size=16M", 0>>),
    Umount = alcove:umount(Port, [Child], "/mnt"),
    [
        ?_assertEqual(ok, Mount),
        ?_assertEqual(ok, Umount)
    ];
tmpfs({_, _Port, _Child}) ->
    ?_assertEqual(ok,ok).

chroot({{unix,linux}, Port, Child}) ->
    Reply = alcove:chroot(Port, [Child], "/bin"),
    ?_assertEqual(ok, Reply);
chroot({{unix,freebsd}, Port, Child}) ->
    Reply = alcove:chroot(Port, [Child], "/rescue"),
    ?_assertEqual(ok, Reply).

chdir({_, Port, Child}) ->
    Reply = alcove:chdir(Port, [Child], "/"),
    CWD = alcove:getcwd(Port, [Child]),
    [
        ?_assertEqual(ok, Reply),
        ?_assertEqual({ok, <<"/">>}, CWD)
    ].

setrlimit({_, Port, Child}) ->
    RLIMIT_NOFILE = alcove:rlimit_define(Port, nofile),
    Reply = alcove:setrlimit(Port, [Child], RLIMIT_NOFILE, #rlimit{cur = 64, max = 64}),
    Rlimit = alcove:getrlimit(Port, [Child], RLIMIT_NOFILE),
    [
        ?_assertEqual(ok, Reply),
        ?_assertEqual({ok, #rlimit{cur = 64, max = 64}}, Rlimit)
    ].

setgid({_, Port, Child}) ->
    Reply = alcove:setgid(Port, [Child], 65534),
    GID = alcove:getgid(Port, [Child]),
    [
        ?_assertEqual(ok, Reply),
        ?_assertEqual(65534, GID)
    ].

setuid({_, Port, Child}) ->
    Reply = alcove:setuid(Port, [Child], 65534),
    UID = alcove:getuid(Port, [Child]),
    [
        ?_assertEqual(ok, Reply),
        ?_assertEqual(65534, UID)
    ].

fork({_, Port, Child}) ->
    Pids = [ alcove:fork(Port, [Child]) || _ <- lists:seq(1, 32) ],
    [Last|_Rest] = lists:reverse(Pids),
    Reply = alcove:getpid(Port, [Child]),

    [
        ?_assertEqual(true, is_integer(Reply)),
        ?_assertEqual({error,eagain}, Last)
    ].

signal({_, Port, _Child}) ->
    {ok, Child1} = alcove:fork(Port),

    TERM = alcove:signal_define(Port, term),

    SA0 = alcove:sigaction(Port, [Child1], TERM, ign),
    Kill0 = alcove:kill(Port, Child1, TERM),
    Pid0 = alcove:getpid(Port, [Child1]),

    SA1 = alcove:sigaction(Port, [Child1], TERM, dfl),
    Kill1 = alcove:kill(Port, Child1, TERM),
    timer:sleep(1000),
    alcove:kill(Port, Child1, 0),
    Search = alcove:kill(Port, Child1, 0),

    [
        ?_assertEqual(ok, SA0),
        ?_assertEqual(ok, Kill0),
        ?_assertEqual(true, is_integer(Pid0)),

        ?_assertEqual(ok, SA1),
        ?_assertEqual(ok, Kill1),
        ?_assertEqual({error,esrch}, Search)
    ].

prctl({linux, Port, _Child}) ->
    {ok, Fork} = alcove:fork(Port),

    % capability is set:
    %   returns 0 | 1 in function result, arg2 = int
    PR_CAPBSET_READ = alcove:prctl_define(Port, capbset_read),
    Reply0 = alcove:prctl(Port, [Fork], PR_CAPBSET_READ, 0, 0,0,0),

    % set process name:
    %   arg2 = char *, up to 16 bytes, NULL terminated
    PR_SET_NAME = alcove:prctl_define(Port, set_name),
    Reply1 = alcove:prctl(Port, [Fork], PR_SET_NAME, <<"test",0>>, 0,0,0),

    % get process name
    %   value returned in arg2 = char *, up to 16 bytes
    PR_GET_NAME = alcove:prctl_define(Port, get_name),
    Reply2 = alcove:prctl(Port, [Fork], PR_GET_NAME, <<0:(17*8)>>, 0,0,0),

    % set parent death signal
    %  arg2 = signal
    PR_SET_PDEATHSIG = alcove:prctl_define(Port, set_pdeathsig),
    Reply3 = alcove:prctl(Port, [Fork], PR_SET_PDEATHSIG, 9, 0,0,0),

    % get parent death signal
    %  arg2 = int *
    PR_GET_PDEATHSIG = alcove:prctl_define(Port, get_pdeathsig),
    Reply4 = alcove:prctl(Port, [Fork], PR_GET_PDEATHSIG, <<0:32>>, 0,0,0),

    [
        ?_assertEqual({ok,1,0,0,0,0}, Reply0),
        ?_assertEqual({ok,0,<<116,101,115,116,0>>,0,0,0}, Reply1),
        ?_assertMatch({ok,0,<<116,101,115,116,0,0,0,0,0,0,0,0,0,0,0,0,0>>,0,0,0}, Reply2),
        ?_assertMatch({ok,0,9,0,0,0}, Reply3),
        ?_assertMatch({ok,0,<<9,0,0,0>>,0,0,0}, Reply4)
    ];
prctl({_, _Port, _Child}) ->
    ?_assertEqual(ok,ok).

execvp({{unix,linux}, Port, Child}) ->
    % cwd = /, chroot'ed in /bin
    Reply = alcove:execvp(Port, [Child], "/busybox", ["/busybox", "sh"]),
    ?_assertEqual(ok, Reply);
execvp({{unix,freebsd}, Port, Child}) ->
    % cwd = /, chroot'ed in /rescue
    Reply = alcove:execvp(Port, [Child], "/sh", ["/sh"]),
    ?_assertEqual(ok, Reply).

stdout({_, Port, Child}) ->
    Reply = alcove:stdin(Port, [Child], "echo 0123456789\n"),
    Stdout = alcove:stdout(Port, [Child], 5000),
    [
        ?_assertEqual(true, Reply),
        ?_assertEqual(<<"0123456789\n">>, Stdout)
    ].

stderr({_, Port, Child}) ->
    Reply = alcove:stdin(Port, [Child], "nonexistent 0123456789\n"),
    Stderr = alcove:stderr(Port, [Child], 5000),
    [
        ?_assertEqual(true, Reply),
        ?_assertEqual(<<"sh: nonexistent: not found\n">>, Stderr)
    ].

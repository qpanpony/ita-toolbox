function ita_pause( seconds )
% ita_pause pauses (sleeps) for given time (units in seconds)
    java.util.concurrent.locks.LockSupport.parkNanos( seconds * 1e9 );
end

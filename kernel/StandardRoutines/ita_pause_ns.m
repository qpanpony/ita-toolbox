function ita_pause_ns( nano_seconds )
% ita_pause_ns pauses (sleeps) for given time (units in nanoseconds)
    java.util.concurrent.locks.LockSupport.parkNanos( nano_seconds );
end

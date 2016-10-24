function ita_pause_us( micro_seconds )
% ita_pause_us pauses (sleeps) for given time (units in micro seconds)
    java.util.concurrent.locks.LockSupport.parkNanos( micro_seconds * 1e3 );
end

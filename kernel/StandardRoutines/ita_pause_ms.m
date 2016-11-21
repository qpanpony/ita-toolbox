function ita_pause_ms( milli_seconds )
% ita_pause_ms pauses (sleeps) for given time (units in milliseconds)
    java.util.concurrent.locks.LockSupport.parkNanos( milli_seconds * 1e6 );
end

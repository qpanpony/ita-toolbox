%% itaVA quick connect
va = VA();

connection_timeout = 5;
connection_attempt_pause = 0.1;

connection_trial_time = 0;
while ~va.get_connected
    if connection_trial_time > 0
        pause( connection_attempt_pause )
    end
    connection_trial_time = connection_trial_time + connection_attempt_pause;
    if connection_trial_time > connection_timeout
        error 'Could not connect to VA, connection timeout.'
    end
    try        
        va.connect
    catch
    end
end

%% Also add current dir to VA search path

va.add_search_path( pwd );

function runFijiMacro(fijiPath, macroPath, macroArgs, timeoutSeconds)
%   runFijiMacro(fijiPath, macroPath, macroArgs, timeoutSeconds)
%
%   This function runs a Fiji macro from within MATLAB using Java's 
%   ProcessBuilder. It supports non-blocking real-time output streaming 
%   and includes timeout protection to avoid indefinite hanging.
%
%   Inputs:
%   -------
%   fijiPath       : Full path to the Fiji executable (e.g., 'D:\Fiji.app\ImageJ-win64.exe').
%   macroPath      : Full path to the .ijm macro script file.
%   macroArgs      : String of arguments passed to the macro (e.g., 'input="..." output="..."').
%   timeoutSeconds : Optional. Timeout threshold in seconds (default: 5 seconds).
%
%   Notes:
%   ------
%   - This function avoids MATLAB's system() call to prevent blocking issues.
%   - Real-time output is printed to MATLAB's Command Window.
%   - If Fiji does not terminate within timeoutSeconds, it is forcibly terminated.
%
%   Author: Qianxi Liang (梁谦禧)
%   Date: 2025-4-20
% -------------------------------------------------------------------------


    if nargin < 4
        timeoutSeconds = 5;
    end

    import java.io.*
    import java.lang.*

    % Construct the command: e.g., {'Fiji.exe', '--headless', '-macro', 'script.ijm', 'args'}
    cmd = {fijiPath, '--headless', '-macro', macroPath, macroArgs};
    pb = ProcessBuilder(cmd);
    pb.redirectErrorStream(true);  % 合并 stderr
    process = pb.start();

    % Open non-blocking reader for stdout
    isr = InputStreamReader(process.getInputStream());
    br = BufferedReader(isr);

    % Start timer for timeout handling
    tStart = tic;
    line = '';
    while true
        % Print output line if available
        if br.ready()
            line = br.readLine();
            if isempty(line), break; end
            disp(char(line));
        end

        % Check whether the process has finished
        try
            exitCode = process.exitValue();
            if exitCode ~= 0
                error('Fiji returned error code: %d', exitCode);
            end
            break;  % Normal completion
        catch
             % Process is still running
        end

        % Check for timeout
        if toc(tStart) > timeoutSeconds
            process.destroy();
            disp("Check whether the reconstruction result is generated " + ...
                "in outputDir. If not, increase timeoutSeconds.");
            return;
        end

        pause(0.05);  % 稍作等待，避免死循环
    end

     % Close I/O streams to release system resources
    br.close();
    isr.close();
end

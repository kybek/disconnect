pipeline {
    agent any
    stages {
        stage('Build') {
            steps {       
                sh '''
                    if [ -d "builds" ]; then
                      rm -rf builds
                    fi
                    mkdir builds
                    mkdir builds/Linux
                    mkdir builds/Windows
                '''
                sh '''
                    set +e
                    godot_server -export_debug 'Linux X11' builds/Linux/[Linux]disconnect
                    godot_server -export_debug 'Windows Desktop' builds/Windows/[Windows]disconnect.exe
                    echo
                '''
                sh '''
                    zip -rj builds/disconnect-$BUILD_NUMBER-Linux.zip builds/Linux/*
                    zip -rj builds/disconnect-$BUILD_NUMBER-Windows.zip builds/Windows/*
                '''
            }
        }
    }
}
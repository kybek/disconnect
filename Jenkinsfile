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
                    mkdir builds/linux
                    mkdir builds/windows
                '''
                sh '''
                    godot_server -export_debug 'Linux X11' builds/linux/disconnect
                    godot_server -export_debug 'Windows Desktop' builds/windows/disconnect.exe
                    echo
                '''
                sh '''
                    zip -rj builds/disconnect-$BUILD_NUMBER-Linux.zip builds/linux/*
                    zip -rj builds/disconnect-$BUILD_NUMBER-Windows.zip builds/windows/*
                '''
            }
        }
    }
}

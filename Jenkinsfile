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
                    zip -rj builds/PepperCarrotGame-master-$BUILD_NUMBER-Linux.zip builds/linux/*
                    zip -rj builds/PepperCarrotGame-master-$BUILD_NUMBER-Windows.zip builds/windows/*
                '''
            }
        }
    }
}
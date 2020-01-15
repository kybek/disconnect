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
                timeout(time: 15, unit: 'SECONDS') {
                    sh '''
                        set +e
                        godot_server -export_debug 'Linux X11' builds/linux/[Linux]disconnect
                        godot_server -export_debug 'Windows Desktop' builds/windows/[Windows]disconnect.exe
                        echo
                    '''
                }
                retry(3) {
                    sh '''
                        zip -rj builds/disconnect-$BUILD_NUMBER-Linux.zip builds/linux/[Linux]disconnect.*
                        zip -rj builds/disconnect-$BUILD_NUMBER-Windows.zip builds/windows/[Windows]disconnect.*
                    '''
                }
            }
        }
    }
}
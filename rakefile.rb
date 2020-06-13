PROJECT_NAME = mender-demo
ROOT_DIRECTORY = File.expand_path(File.dirname(__FILE__))

def mkdir_f(dir)
    mkdir dir unless File.directory?(dir)
end


task :docker do
    sh "docker build -t #{PROJECT_NAME}-build #{ROOT_DIRECTORY}"
end


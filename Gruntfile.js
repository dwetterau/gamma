module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        sync: {
            main: {
                files: [
                    {cwd: 'src', src: './views/**', dest: 'bin/'},
                    {cwd: 'src', src: ['./public/**', '!./public/**/*.coffee'], dest: 'bin/'},
                    {
                        cwd: 'node_modules/material-design-icons/sprites',
                        src: './svg-sprite/*.css',
                        dest: 'bin/public/stylesheets/external/'
                    }
                ]
            }
        },
        less: {
            development: {
                files: {
                    'bin/public/stylesheets/less_main.css': 'src/public/stylesheets/external/less/main.less'
                }
            }
        },
        watch: {
            app: {
                files: [
                    'src/public/**/*.coffee',
                    'src/components/**/*.coffee',
                    'src/lib/common/**/*.coffee'
                ],
                tasks: ['browserify']
            },
            server: {
                files: [
                    'src/models/**/*.coffee',
                    'src/controllers/**/*.coffee',
                    'src/lib/**/*.coffee'
                ],
                tasks: ['coffee']
            },
            templates: {
                files: [
                    'src/views/**',
                    'src/public/**/*.css',
                    'src/public/**/*.js',
                    'src/public/**/*.ico'
                ],
                tasks: ['sync']
            },
            lessFiles: {
                files: [
                    'src/public/**/*.less'
                ],
                tasks: ['less']
            }
        },
        browserify: {
            dist: {
                files: {
                    'bin/public/js/bundle.js': 'src/public/js/index.coffee'
                },
                options: {
                    transform: ["coffee-reactify"],
                    browserifyOptions: {
                        debug: true,
                        extensions: ['.cjsx', '.coffee']
                    }
                }
            }
        },
        coffee: {
            glob_to_multiple: {
                expand: true,
                flatten: false,
                cwd: 'src',
                src: [
                    './controllers/**/*.coffee',
                    './lib/**/*.coffee',
                    './models/**/*.coffee',
                    './oneoff/**/*.coffee',
                    './routes/**/*.coffee',
                    './tests/**/*.coffee',
                    './index.coffee'
                ],
                dest: 'bin',
                ext: '.js'
            }
        },
        nodemon: {
            dev: {
                script: 'bin/index.js',
                options: {
                    nodeArgs: ['--debug'],
                    watch: ['bin']
                }
            }
        }
    });

    grunt.loadNpmTasks('grunt-browserify');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-sync');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-nodemon');

    grunt.registerTask('default', ['coffee', 'browserify', 'less', 'sync']);
};
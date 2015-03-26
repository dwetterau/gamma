module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        watch: {
            app: {
                files: ['src/**/*.coffee', 'src/**/*.css', 'src/**/*.js'],
                tasks: ['cjsx']
            }
        },

        cjsx: {
            compile: {
                files: {
                    'bin/public/javascripts/bundle.js': 'src/public/javascripts/index.js'
                }
            }
        }

    });

    grunt.loadNpmTasks('grunt-coffee-react');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-nodemon');

    grunt.registerTask('default', ['cjsx']);
};
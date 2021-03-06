/*    advgetopt.h -- a replacement to the Unix getopt() implementation
 *    Copyright (C) 2012-2015  Made to Order Software Corporation
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License along
 *    with this program; if not, write to the Free Software Foundation, Inc.,
 *    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 *    Authors
 *    Alexis Wilke   alexis@m2osw.com
 */
#ifndef ADVGETOPT_H
#define ADVGETOPT_H

/** \file
 * \brief Definitions of the advanced getopt class.
 *
 * The library offers an advanced way to parse command line arguments
 * and configuration files in a seamless manner. This class is what is
 * used all around for that purpose.
 */
#include    "debian_export.h"
#include    "controlled_vars/controlled_vars_auto_init.h"
#include    "controlled_vars/controlled_vars_auto_enum_init.h"

#include    <stdint.h>
#include    <map>
#include    <stdexcept>
#include    <string>
#include    <vector>
#include    <limits>

namespace advgetopt
{

// generic getopt exception
class getopt_exception : public std::runtime_error
{
public:
    getopt_exception(const std::string& msg) : runtime_error(msg) {}
};

// problem with a default argument
class getopt_exception_default : public getopt_exception
{
public:
    getopt_exception_default(const std::string& msg) : getopt_exception(msg) {}
};

// trying to get an undefined option
class getopt_exception_undefined : public getopt_exception
{
public:
    getopt_exception_undefined(const std::string& msg) : getopt_exception(msg) {}
};

// something wrong in the user options
class getopt_exception_invalid : public getopt_exception
{
public:
    getopt_exception_invalid(const std::string& msg) : getopt_exception(msg) {}
};

// usage() was called and the library was compiled in debug mode
class getopt_exception_exiting : public getopt_exception
{
public:
    getopt_exception_exiting(const std::string& msg) : getopt_exception(msg) {}
};


// getopt is a advanced class that parses your command line
// arguments and make them accessible by name via a
// standard map
class DEBIAN_PACKAGE_EXPORT getopt
{
public:
    enum status_t
    {
        no_error,
        no_error_nobr,
        warning,
        error,
        fatal
    };

    static const unsigned char GETOPT_FLAG_ENVIRONMENT_VARIABLE = 0x01;
    static const unsigned char GETOPT_FLAG_CONFIGURATION_FILE   = 0x02;
    static const unsigned char GETOPT_FLAG_SHOW_USAGE_ON_ERROR  = 0x04;
    static const unsigned char GETOPT_FLAG_ALIAS                = 0x08;

    enum argument_mode_t
    {
        no_argument,
        required_argument,
        optional_argument,
        required_multiple_argument,
        optional_multiple_argument,
        required_long,
        optional_long,
        required_multiple_long,
        optional_multiple_long,
        default_argument,
        default_multiple_argument,
        help_argument,
        end_of_options
    };

    struct DEBIAN_PACKAGE_EXPORT option
    {
        char                f_opt;      // letter option (or '\0')
        unsigned char       f_flags;    // set of flags
        const char *        f_name;     // name of the option (i.e. "test" for --test, or NULL)
        const char *        f_default;  // a default value if not NULL
        const char *        f_help;     // help for this option, if NULL it's a hidden option; if ALIAS then this is the actual alias
        argument_mode_t     f_arg_mode;
    };

                    getopt(int argc, char *argv[], const option *opts, const std::vector<std::string> configuration_files, const char *environment_variable_name);

    void            reset(int argc, char *argv[], const option *opts, const std::vector<std::string> configuration_files, const char *environment_variable_name);

    bool            is_defined(const std::string& name) const;
    int             size(const std::string& name) const;
    const char *    get_default(const std::string& name) const;
    long            get_long(const std::string& name, int idx = 0, long min = std::numeric_limits<long>::min(), long max = std::numeric_limits<long>::max());
    std::string     get_string(const std::string& name, int idx = 0) const;
    std::string     get_program_name() const;
    std::string     get_program_fullname() const;
    void            usage(status_t status, const char *msg, ...);

private:
    struct DEBIAN_PACKAGE_EXPORT optmap_info
    {
        controlled_vars::fbool_t    f_cvt;  // whether f_int is defined (true) or not (false)
        controlled_vars::zint32_t   f_idx;  // index in f_options
        std::vector<long>           f_int;
        std::vector<std::string>    f_val;
    };
    typedef std::map<std::string, optmap_info> optmap_t;

    void parse_arguments(int argc, char *argv[], const option *opts, int def_opt, std::map<char, int> opt_by_short_name, std::map<std::string, int> opt_by_long_name, bool only_environment_variable);
    void add_options(const option *opt, int& i, int argc, char **argv);
    void add_option(const option *opt, const char *value);

    std::string         f_program_fullname;
    std::string         f_program_name;
    const option *      f_options;
    optmap_t            f_map;
};



}   // namespace advgetopt
#endif
//#ifndef ADVGETOPT_H
// vim: ts=4 sw=4 et

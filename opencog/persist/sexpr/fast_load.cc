/*
 * fast_load.cc
 * Fast load of Atomese in s-expression format.
 *
 * Copyright (C) 2020 Alexey Potapov, Anatoly Belikov
 *
 * Authors: Alexey Potapov
 *          Anatoly Belikov
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License v3 as
 * published by the Free Software Foundation and including the exceptions
 * at http://opencog.org/wiki/Licenses
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program; if not, write to:
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

#include <opencog/atomspace/AtomSpace.h>

#include "fast_load.h"
#include "Sexpr.h"

using namespace opencog;

static Handle parseStream(std::istream& in, AtomSpace& as)
{
    Handle h;
    size_t expr_cnt = 0;
    size_t line_cnt = 0;
    int pcount = 0;
    size_t r = 0;

    std::string expr;
    while (!in.eof())
    {
        std::string line;
        std::getline(in, line);
        line_cnt++;
        expr += line;
        while (true)
        {
            size_t l = 0;
            r = expr.length();

            // Zippy the Pinhead says: Are we having fun yet?
            pcount = Sexpr::get_next_expr(expr, l, r, line_cnt);

            // Trim away comments at end of line
            if (0 < pcount)
            {
                expr = expr.substr(l, r - l);
                break;
            }

            // Nothing to do.
            if (l == r)
                break;

            expr_cnt++;
            h = as.add_atom(Sexpr::decode_atom(expr, l, r, line_cnt));
            expr = expr.substr(r + 1);
        }
    }

    if (0 < pcount)
        throw std::runtime_error(
            "Unbalanced parenthesis >>" + expr.substr(r) + "<<");

    return h;
}

/// load_file -- load the given file into the given AtomSpace.
void opencog::load_file(const std::string& fname, AtomSpace& as)
{
    std::ifstream f(fname);
    if (not f.is_open())
        throw std::runtime_error("Cannot find file >>" + fname + "<<");

    parseStream(f, as);
    
    f.close();
}

// Parse an Atomese string expression and return a Handle to the parsed atom
// The expression is assumed not to contain any newlines!
Handle opencog::parseExpression(const std::string& expr, AtomSpace &as)
{
    size_t l = 0;
    size_t r = expr.length();
    size_t rr = r;

    Handle h;

    while (true)
    {
        // Zippy the Pinhead says: Are we having fun yet?
        int pcount = Sexpr::get_next_expr(expr, l, r, 0);

        // Finished.
        if (l == r)
            break;

        if (0 < pcount)
            throw std::runtime_error(
                "Unbalanced parenthesis >>" + expr.substr(r) + "<<");

        h = as.add_atom(Sexpr::decode_atom(expr, l, r, 0));
        l = r + 1;
        r = rr;
    }

    return h;
}

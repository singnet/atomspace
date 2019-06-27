/*
 * opencog/atoms/reduct/FoldLink.cc
 *
 * Copyright (C) 2015, 2018 Linas Vepstas
 * All Rights Reserved
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

#include <limits>

#include <opencog/atoms/atom_types/atom_types.h>
#include <opencog/atoms/atom_types/NameServer.h>
#include <opencog/atoms/core/NumberNode.h>
#include "FoldLink.h"

using namespace opencog;

FoldLink::FoldLink(const HandleSeq& oset, Type t)
    : FunctionLink(oset, t)
{
	init();
}

FoldLink::FoldLink(const Link& l)
    : FunctionLink(l)
{
	init();
}

void FoldLink::init(void)
{
	Type tscope = get_type();
	if (not nameserver().isA(tscope, FOLD_LINK))
		throw InvalidParamException(TRACE_INFO, "Expecting a FoldLink");
}

// ===============================================================

/// delta_reduce() -- delta-reduce a right-fold by recursively
/// calling kons.  Recall the defintion of delta-reduction: it is
/// that operation by which a function with arguments is replaced
/// by the value that function would have for these values.
/// For example, the delta-reduction of 2+2 is 4.
///
/// Actually, what is implemete here is not pure delta-reduction.
/// If the arguments to Fold are executale, then they are executed
/// first, and only then is the delta-reduction performed.
ValuePtr FoldLink::delta_reduce(AtomSpace* as, bool silent) const
{
	ValuePtr expr = knil;

	// Loop over the outgoing set, kons'ing away.
	// This is right to left.
	size_t osz = _outgoing.size();
	for (int i = osz-1; 0 <= i; i--)
	{
		Handle h(_outgoing[i]);

		// Special-case hack for atoms returned by the pattern matcher.
		// ... The pattern matcher returns things wrapped in a SetLink.
		// Unwrap them and use them.
		if (SET_LINK == h->get_type() and h->get_arity() == 1)
		{
			h = h->getOutgoingAtom(0);
		}

		// Well, we lied; this is not pure delta-reduction. If the
		// arguments to fold are executable atoms, then execute them,
		// and fold in the results.
		//
		// Performance ... maybe it is faster to call the nameserver
		// instead?
		// if (nameserver().isA(h->get_type(), FUNCTION_LINK))
		if (h->is_executable())
		{
			expr = kons(as, silent, h->execute(as, silent), expr);
		}
		else
		{
			expr = kons(as, silent, h, expr);
		}
	}

	return expr;
}

// ===========================================================

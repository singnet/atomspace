/*
 * opencog/atoms/reduct/TimesLink.h
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

#ifndef _OPENCOG_TIMES_LINK_H
#define _OPENCOG_TIMES_LINK_H

#include <opencog/atoms/reduct/ArithmeticLink.h>

namespace opencog
{
/** \addtogroup grp_atomspace
 *  @{
 */

/**
 * The TimesLink implements the mathematical operation of "times".
 */
class TimesLink : public ArithmeticLink
{
protected:
	static Handle one;
	ValuePtr kons(AtomSpace*, bool,
	              const ValuePtr&, const ValuePtr&) const;

	void init(void);

public:
	TimesLink(const HandleSeq&, Type=TIMES_LINK);
	TimesLink(const Handle& a, const Handle& b);
	TimesLink(const Link&);

	static Handle factory(const Handle&);
};

typedef std::shared_ptr<TimesLink> TimesLinkPtr;
static inline TimesLinkPtr TimesLinkCast(const Handle& h)
   { AtomPtr a(h); return std::dynamic_pointer_cast<TimesLink>(a); }
static inline TimesLinkPtr TimesLinkCast(AtomPtr a)
   { return std::dynamic_pointer_cast<TimesLink>(a); }

#define createTimesLink std::make_shared<TimesLink>

/** @}*/
}

#endif // _OPENCOG_TIMES_LINK_H

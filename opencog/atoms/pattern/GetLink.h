/*
 * opencog/atoms/pattern/GetLink.h
 *
 * Copyright (C) 2019 Linas Vepstas
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
#ifndef _OPENCOG_GET_LINK_H
#define _OPENCOG_GET_LINK_H

#include <opencog/atoms/pattern/PatternLink.h>

namespace opencog
{
/** \addtogroup grp_atomspace
 *  @{
 */
class GetLink : public PatternLink
{
protected:
	void init(void);
	virtual HandleSet do_execute(AtomSpace*, bool silent);

public:
	GetLink(const HandleSeq&, Type=GET_LINK);
	explicit GetLink(const Link &l);

	virtual bool is_executable() const { return true; }
	virtual ValuePtr execute(AtomSpace*, bool silent=false);

	static Handle factory(const Handle&);
};

typedef std::shared_ptr<GetLink> GetLinkPtr;
static inline GetLinkPtr GetLinkCast(const Handle& h)
	{ AtomPtr a(h); return std::dynamic_pointer_cast<GetLink>(a); }
static inline GetLinkPtr GetLinkCast(AtomPtr a)
	{ return std::dynamic_pointer_cast<GetLink>(a); }

#define createGetLink std::make_shared<GetLink>

/** @}*/
}

#endif // _OPENCOG_GET_LINK_H

/*
 * opencog/atoms/pattern/JoinLink.h
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
#ifndef _OPENCOG_JOIN_LINK_H
#define _OPENCOG_JOIN_LINK_H

#include <opencog/atoms/core/PrenexLink.h>
#include <opencog/atoms/value/QueueValue.h>

namespace opencog
{
/** \addtogroup grp_atomspace
 *  @{
 */
class JoinLink : public PrenexLink
{
protected:
	void init(void);
	virtual QueueValuePtr do_execute(AtomSpace*, bool silent);

public:
	JoinLink(const HandleSeq&&, Type=JOIN_LINK);

	JoinLink(const JoinLink&) = delete;
	JoinLink operator=(const JoinLink&) = delete;

	virtual bool is_executable() const { return true; }
	virtual ValuePtr execute(AtomSpace*, bool silent=false);

	static Handle factory(const Handle&);
};

typedef std::shared_ptr<JoinLink> JoinLinkPtr;
static inline JoinLinkPtr JoinLinkCast(const Handle& h)
	{ AtomPtr a(h); return std::dynamic_pointer_cast<JoinLink>(a); }
static inline JoinLinkPtr JoinLinkCast(AtomPtr a)
	{ return std::dynamic_pointer_cast<JoinLink>(a); }

#define createJoinLink std::make_shared<JoinLink>

/** @}*/
}

#endif // _OPENCOG_JOIN_LINK_H

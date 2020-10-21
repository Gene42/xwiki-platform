/*
 * See the NOTICE file distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */
package com.xpn.xwiki.web;

import org.xwiki.configuration.ConfigurationSource;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.apache.struts2.RequestUtils;
import org.apache.struts2.dispatcher.mapper.ActionMapper;
import org.apache.struts2.dispatcher.mapper.ActionMapping;
import org.apache.struts2.dispatcher.mapper.DefaultActionMapper;

import com.opensymphony.xwork2.config.ConfigurationManager;
import com.xpn.xwiki.internal.XWikiCfgConfigurationSource;

/**
 * Customize the behavior of the default {@link ActionMapper} to take into account the configured path based wiki
 * prefix.
 * 
 * @version $Id$
 */
public class XWikiActionMapper extends DefaultActionMapper
{
    @Override
    public ActionMapping getMapping(HttpServletRequest request, ConfigurationManager configManager)
    {
        String path = request.getPathInfo();
        if (path == null) {
            path = RequestUtils.getServletPath(request);
        }

        if (path == null) {
            return null;
        }

        ConfigurationSource configuration =
            Utils.getComponent(ConfigurationSource.class, XWikiCfgConfigurationSource.ROLEHINT);
        // Remove /wikiname part if the struts action is /wiki
        if (request.getServletPath()
            .equals("/" + configuration.getProperty("xwiki.virtual.usepath.servletpath", "wiki"))) {
            int wikiNameIndex = path.indexOf("/", 1);
            if (wikiNameIndex == -1) {
                path = "";
            } else {
                path = path.substring(wikiNameIndex);
            }
        }

        String name;
        if (StringUtils.countMatches(path, "/") <= 2) {
            if (path.startsWith("/xmlrpc/")) {
                name = "xmlrpc";
            } else {
                name = "view";
            }
        } else {
            name = path.substring(0, path.indexOf("/", 1));
            if (name.charAt(0) == '/') {
                name = name.substring(1);
            }
        }

        ActionMapping mapping = new ActionMapping();
        mapping.setName(name);
        return mapping;
    }
}

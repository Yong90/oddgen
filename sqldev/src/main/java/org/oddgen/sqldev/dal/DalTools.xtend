/*
 * Copyright 2015-2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.io.StringReader
import java.sql.CallableStatement
import java.sql.Clob
import java.sql.Connection
import java.sql.SQLException
import java.sql.Types
import java.util.List
import javax.xml.parsers.DocumentBuilderFactory
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.generators.model.Node
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.BadSqlGrammarException
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Document
import org.xml.sax.InputSource

@Loggable(LoggableConstants.DEBUG)
class DalTools {
	private static int MAX_DEPTH = 2
	private int depth = 0
	private Connection conn
	private JdbcTemplate jdbcTemplate

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
	}

	def removeCarriageReturns(String plsql) {
		// fix for issue #3: no CR in PL/SQL blocks on Ora DB 10.2 - see MOS note 1399110.1 for details.
		return plsql.replace("\r", "")
	}

	def String getString(String plsql) {
		depth++
		var String result = null
		try {
			result = jdbcTemplate.execute(plsql.removeCarriageReturns, new CallableStatementCallback<String>() {
				override String doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.VARCHAR);
					cs.execute
					return cs.getString(1);
				}
			})
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			if (e.message.contains("ORA-04068") && depth < MAX_DEPTH) {
				// catch : existing state of packages has been discarded
				Logger.debug(this, '''Failed with ORA-04068. Try again («depth»).''')
				result = plsql.string
			} else {
				Logger.error(this, e.message)

			}
		} finally {
			depth--
		}
		return result
	}

	def Document getDoc(String plsql) {
		depth++
		var Document doc = null
		try {
			val resultClob = jdbcTemplate.execute(plsql.removeCarriageReturns, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			val docBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
			val resultString = resultClob.getSubString(1, resultClob.length as int)
			doc = docBuilder.parse(new InputSource(new StringReader(resultString)))
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			if (e.message.contains("ORA-04068") && depth < MAX_DEPTH) {
				// catch : existing state of packages has been discarded
				Logger.debug(this, '''Failed with ORA-04068. Try again («depth»).''')
				doc = plsql.doc
			} else {
				Logger.error(this, e.message)

			}
		} finally {
			depth--
		}
		return doc
	}

	def String escapeSingleQuotes(String value) {
		return value.replace("'", "''")
	}

	def CharSequence toPlsql(List<Node> nodes) '''
		«IF nodes !== null»
			«FOR node : nodes»
				l_node.id              := '«node.id»';
				l_node.parent_id       := «IF node.parentId === null»NULL«ELSE»'«node.parentId»'«ENDIF»;
				l_node.name            := «IF node.name === null»NULL«ELSE»'«node.name»'«ENDIF»;
				l_node.description     := «IF node.description === null»NULL«ELSE»'«node.description.escapeSingleQuotes»'«ENDIF»;
				l_node.icon_name       := «IF node.iconName === null»NULL«ELSE»'«node.iconName»'«ENDIF»;
				l_node.icon_base64     := «IF node.iconBase64 === null»NULL«ELSE»'«node.iconBase64»'«ENDIF»;
				«IF node.params === null»
					l_node.params          := NULL;
				«ELSE»
					«IF node.params === null»
						l_node.params          := NULL;
					«ELSE»
						«FOR key : node.params.keySet»
							l_node.params('«key.escapeSingleQuotes»') := '«node.params.get(key)»';
						«ENDFOR»
					«ENDIF»
				«ENDIF»
				l_node.leaf            := «IF node.leaf»TRUE«ELSE»FALSE«ENDIF»;
				l_node.generatable     := «IF node.generatable»TRUE«ELSE»FALSE«ENDIF»;
				l_node.multiselectable := «IF node.multiselectable»TRUE«ELSE»FALSE«ENDIF»;
				l_nodes.extend;
				l_nodes(l_nodes.count) := l_node;
			«ENDFOR»
		«ENDIF»
	'''

	def toObjectType(List<Node> nodes) {
		var String objectType = null
		if (nodes !== null && nodes.size > 0) {
			val params = nodes?.get(0)?.params
			if (params !== null) {
				objectType = params.get("Object type")
			}
		}
		return objectType
	}

	def toObjectName(List<Node> nodes) {
		var String objectName = null
		if (nodes !== null && nodes.size > 0) {
			val params = nodes?.get(0)?.params
			if (params !== null) {
				objectName = nodes?.get(0)?.params?.get("Object name")
			}
		}
		return objectName
	}

}

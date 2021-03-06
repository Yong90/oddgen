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
package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.io.ByteArrayInputStream
import java.net.URL
import java.util.Arrays
import java.util.List
import javax.imageio.ImageIO
import javax.swing.ImageIcon
import javax.xml.bind.DatatypeConverter
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.generators.model.NodeTools
import org.oddgen.sqldev.model.GeneratorSelection
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class NodeNode extends DefaultContainer {
	var GeneratorSelection gensel;
	val extension NodeTools nodeTools = new NodeTools

	new(URL url, GeneratorSelection gensel) {
		super(url)
		this.gensel = gensel
	}

	override getIcon() {
		try {
			if (gensel.node.iconName !== null && !gensel.node.iconName.empty) {
				return OddgenResources.getIcon(gensel.node.iconName)
			} else if (gensel.node.iconBase64 !== null && !gensel.node.iconBase64.empty) {
				var icon = new ImageIcon
				val decodedBytes = DatatypeConverter.parseBase64Binary(gensel.node.iconBase64);
				if (decodedBytes.length > 0) {
					val bis = new ByteArrayInputStream(decodedBytes);
					icon.image = ImageIO.read(bis);
					bis.close();
					return icon
				}
			} else {
				val entries = Arrays.asList(gensel.node.id.split("\\."))
				if (gensel.node.leaf) {
					// assuming that a node is an object name and parent is an object type
					val id = if (entries.size >= 2) {entries.get(entries.size - 2)} else {gensel.node.parentId}
					if (id !== null) {
						if (id.startsWith("TABLE") || id == "CLUSTER") {
							return OddgenResources.getIcon("TABLE_ICON")
						} else if (id == "VIEW") {
							return OddgenResources.getIcon("VIEW_ICON")
						} else if (id.startsWith("INDEX")) {
							return OddgenResources.getIcon("INDEX_ICON")
						} else if (id == "SYNONYM") {
							return OddgenResources.getIcon("SYNONYM_ICON")
						} else if (id == "SEQUENCE") {
							return OddgenResources.getIcon("SEQUENCE_ICON")
						} else if (id == "PROCEDURE") {
							return OddgenResources.getIcon("PROCEDURE_ICON")
						} else if (id == "FUNCTION") {
							return OddgenResources.getIcon("FUNCTION_ICON")
						} else if (id.startsWith("PACKAGE")) {
							return OddgenResources.getIcon("PACKAGE_ICON")
						} else if (id == "TRIGGER") {
							return OddgenResources.getIcon("TRIGGER_ICON")
						} else if (id.startsWith("TYPE")) {
							return OddgenResources.getIcon("TYPE_ICON")
						} else if (id == "LIBRARY") {
							return OddgenResources.getIcon("LIBRARY_ICON")
						} else if (id == "DIRECTORY") {
							return OddgenResources.getIcon("DIRECTORY_ICON")
						} else if (id == "QUEUE") {
							return OddgenResources.getIcon("QUEUE_ICON")
						} else if (id.startsWith("JAVA")) {
							return OddgenResources.getIcon("JAVA_ICON")
						} else if (id == "MATERIALIZED VIEW" || id == "REWRITE EQUIVALENCE") {
							return OddgenResources.getIcon("MATERIALIZED_VIEW_ICON")
						} else if (id == "EDITION") {
							return OddgenResources.getIcon("EDITION_ICON")
						} else if (id.startsWith("JOB")) {
							return OddgenResources.getIcon("JOB_ICON")
						} else if (id == "DATABASE LINK") {
							return OddgenResources.getIcon("DBLINK_ICON")
						} else if (id == "CONSUMER GROUP" || id.contains("CONTEXT") || id == "DESTINATION" ||
							id.startsWith("LOB") || id == "OPERATOR" || id == "PROGRAM" || id == "RESOURCE PLAN" ||
							id.startsWith("RULE") || id.startsWith("SCHEDULE") || id == "UNIFIED AUDIT POLICY" ||
							id == "WINDOW" || id == "XML SCHEMA" || id == "DIMENSION" || id == "SUBSCRIPTION" ||
							id == "LOCATION" || id == "CAPTURE" || id == "APPLY" || id == "CHAIN" || id == "FILE GROUP" ||
							id == "MINING MODEL" || id == "ASSEMBLY" || id == "CREDENTIAL" || id == "CUBE DIMENSION" ||
							id == "CUBE" || id == "MEASURE FOLDER" || id == "CUBE BUILD PROCESS" || id == "FILE WATCHER" ||
							id == "SQL TRANSLATION PROFILE") {
							return OddgenResources.getIcon("OBJECT_ICON")
						} else {
							return OddgenResources.getIcon("UNKNOWN_ICON")
						}
					} else {
						return OddgenResources.getIcon("UNKNOWN_ICON")
					}
				} else {
					// assuming that a node is an object type
					val id = if (entries.size >= 1) {entries.get(entries.size - 1)} else {gensel.node.id}
					if (id !== null) { 
						if (id.startsWith("TABLE") || id == "CLUSTER") {
							return OddgenResources.getIcon("TABLE_FOLDER_ICON")
						} else if (id == "VIEW") {
							return OddgenResources.getIcon("VIEW_FOLDER_ICON")
						} else if (id.startsWith("INDEX")) {
							return OddgenResources.getIcon("INDEX_FOLDER_ICON")
						} else if (id == "SYNONYM") {
							return OddgenResources.getIcon("SYNONYM_FOLDER_ICON")
						} else if (id == "SEQUENCE") {
							return OddgenResources.getIcon("SEQUENCE_FOLDER_ICON")
						} else if (id == "PROCEDURE") {
							return OddgenResources.getIcon("PROCEDURE_FOLDER_ICON")
						} else if (id == "FUNCTION") {
							return OddgenResources.getIcon("FUNCTION_FOLDER_ICON")
						} else if (id.startsWith("PACKAGE")) {
							return OddgenResources.getIcon("PACKAGE_FOLDER_ICON")
						} else if (id == "TRIGGER") {
							return OddgenResources.getIcon("TRIGGER_FOLDER_ICON")
						} else if (id.startsWith("TYPE")) {
							return OddgenResources.getIcon("TYPE_FOLDER_ICON")
						} else if (id == "LIBRARY") {
							return OddgenResources.getIcon("LIBRARY_FOLDER_ICON")
						} else if (id == "DIRECTORY") {
							return OddgenResources.getIcon("DIRECTORY_FOLDER_ICON")
						} else if (id == "QUEUE") {
							return OddgenResources.getIcon("QUEUE_FOLDER_ICON")
						} else if (id.startsWith("JAVA")) {
							return OddgenResources.getIcon("JAVA_FOLDER_ICON")
						} else if (id == "MATERIALIZED VIEW" || id == "REWRITE EQUIVALENCE") {
							return OddgenResources.getIcon("MATERIALIZED_VIEW_FOLDER_ICON")
						} else if (id == "EDITION") {
							return OddgenResources.getIcon("EDITION_FOLDER_ICON")
						} else if (id.startsWith("JOB")) {
							return OddgenResources.getIcon("JOB_FOLDER_ICON")
						} else if (id == "DATABASE LINK") {
							return OddgenResources.getIcon("DBLINK_FOLDER_ICON")
						} else if (id == "CONSUMER GROUP" || id.contains("CONTEXT") || id == "DESTINATION" ||
							id.startsWith("LOB") || id == "OPERATOR" || id == "PROGRAM" || id == "RESOURCE PLAN" ||
							id.startsWith("RULE") || id.startsWith("SCHEDULE") || id == "UNIFIED AUDIT POLICY" ||
							id == "WINDOW" || id == "XML SCHEMA" || id == "DIMENSION" || id == "SUBSCRIPTION" ||
							id == "LOCATION" || id == "CAPTURE" || id == "APPLY" || id == "CHAIN" || id == "FILE GROUP" ||
							id == "MINING MODEL" || id == "ASSEMBLY" || id == "CREDENTIAL" || id == "CUBE DIMENSION" ||
							id == "CUBE" || id == "MEASURE FOLDER" || id == "CUBE BUILD PROCESS" || id == "FILE WATCHER" ||
							id == "SQL TRANSLATION PROFILE") {
							return OddgenResources.getIcon("OBJECT_FOLDER_ICON")
						} else {
							return OddgenResources.getIcon("UNKNOWN_FOLDER_ICON")
						}
					} else {
						return OddgenResources.getIcon("UNKNOWN_FOLDER_ICON")
					}
				}
			}
		} catch (Exception e) {
			Logger.error(this, '''Could not produce a valid icon for«IF gensel.node.leaf» leaf«ENDIF» node «gensel.node.id». Used default icon instead.''')
			if (gensel.node.leaf) {
				return OddgenResources.getIcon("UNKNOWN_ICON")
			} else {
				return OddgenResources.getIcon("UNKNOWN_FOLDER_ICON")
			}
		}
	}

	def void openEagerlyLoadedChildren(List<Node> nodes) {
		for (node : nodes.filter[it.parentId == gensel.node.id]) {
			val GeneratorSelection gs = new GeneratorSelection
			gs.generator = gensel.generator
			gs.node = node
			val nodeNode = new NodeNode(URLFactory.newURL(this.URL, gs.node.id), gs)
			this.add(nodeNode)
			if (!gs.node.isLeaf) {
				nodeNode.openEagerlyLoadedChildren(nodes)
			}
		}
		UpdateMessage.fireStructureChanged(this)
		this.markDirty(false)
	}

	def openBackground() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		if (conn !== null) {
			val nodes = gensel.generator.getNodes(conn, gensel.node.id)
			for (n : nodes.filter[it.parentId == gensel.node.id]) {
				val gs = new GeneratorSelection
				gs.generator = gensel.generator
				gs.node = n
				val nodeNode = new NodeNode(URLFactory.newURL(this.URL, gs.node.id), gs)
				this.add(nodeNode)
				if (!gs.node.isLeaf) {
					nodeNode.openEagerlyLoadedChildren(nodes)
				}
			}
		}
		UpdateMessage.fireStructureChanged(this)
		this.markDirty(false)
	}

	override openImpl() {
		if (!gensel.node.leaf && !this.children.hasNext) {
			val Runnable runnable = [|openBackground]
			val thread = new Thread(runnable)
			thread.name = "oddgen non-leaf node"
			thread.start
		}
	}

	override getLongLabel() {
		return gensel.node.displayDescription
	}

	override getShortLabel() {
		return gensel.node.displayName
	}

	override getToolTipText() {
		return gensel.node.displayDescription
	}

	override mayHaveChildren() {
		return !gensel.node.isLeaf
	}

	override getData() {
		return gensel
	}

}

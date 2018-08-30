int versionFromTag(tag) {
	return tag.substring(1)
}

def buildUbuntu16 = [
	label: "build-ubuntu16",
	pkgName: "manifold_${versionFromTag(tag).replace('-','~')}-1_amd64.deb",
	metaName: "manifold_${versionFromTag(tag).replace('-','~')}-1_amd64.deb.metadata.json",
	target: 'ubuntu16'
]

def buildUbuntu18 = [
	label: "build-ubuntu18",
	pkgName: "manifold_${versionFromTag(tag).replace('-','~')}-1_amd64.deb",
	metaName: "manifold_${versionFromTag(tag).replace('-','~')}-1_amd64.deb.metadata.json",
	target: 'ubuntu18'
]

def buildCentos7 = [
	label: "build-centos7",
	pkgName: "manifold-${versionFromTag(tag).replace('-','~')}-1.el7.x86_64.rpm",
	metaName: "manifold-${versionFromTag(tag).replace('-','~')}-1.el7.x86_64.rpm.metadata.json",
	target: 'centos7'
]

def builds = [buildUbuntu16, buildUbuntu18, buildCentos7]

def branches = [:]
for (x in builds) {
	def build = x
	def buildLabel = build['label']
	def pkgName = build['pkgName']
	def pkgPath = "pkg/${pkgName}"
	def buildTarget = build['target']
	def target = "/mnt/nfs/manifold_build/dist/${buildTarget}/"
	def metaName = build['metaName']
	def metaPath = "pkg/${metaName}"
	branches[buildLabel] = {
		node(buildLabel) {

			stage("Build on ${buildTarget}") {
				echo omnibusBuild
				sh "if [ ! -d \".git\" ]; then git clone https://github.com/ManifoldScholar/omnibus-manifold.git .; fi"
				echo "Checking out tag: ${tag}"
				sh "git fetch --all --tags --force"
				sh "git reset --hard ${tag}"
				if (omnibusBuild == "Yes") {
				  // Triggering errors on Jenkins Ubuntu 16 slave.
					//sh "source ~/scripts/build_env.sh"
					sh "~/.rbenv/shims/bundle install -j 3 --binstubs"
					sh "~/.rbenv/shims/rake build:package[\"info\"]"
				} else {
					echo "Skipping build stage."
				}
				echo "Checking for package: ${pkgPath}"
				sh "if [ ! -d ${target} ]; then mkdir -p ${target}; fi"
				if (fileExists(pkgPath)) {
					sh "cp -f ${pkgPath} ${target}"
				} else {
					error("Build failed the expected package was missing.")
				}
				if (fileExists(metaPath)) {
					sh "cp -f ${metaPath} ${target}"
				} else {
					error("Build failed the expected package metadata was missing.")
				}
				googleStorageUpload(
					bucket: "gs://manifold-dist",
					credentialsId: 'manifold-scholarship',
					pattern: "${target}${pkgName}*",
					pathPrefix: "mnt/nfs/manifold_build/dist/",
					sharedPublicly: true
				)
			}
		}
	}
}

stage('Build in Parallel') {
	parallel branches
}

stage('Tag Build') {
    currentBuild.displayName = tag
}

node('master') {
	stage ("Update Manifest") {
		build 'update-manifest'
	}
}

default: build

.PHONY: build
build:
	echo "$$ABUILD_PRIVATE_KEY" | base64 -d > ~/.abuild/"$$CIRCLE_PROJECT_USERNAME".rsa
	echo "$$ABUILD_PUBLIC_KEY" | base64 -d > ~/.abuild/"$$CIRCLE_PROJECT_USERNAME".pug.rsa
	echo PACKAGER_PRIVKEY=\"/home/buildozer/.abuild/"$$CIRCLE_PROJECT_USERNAME".rsa\" >> ~/.abuild/abuild.conf
	find * -mindepth 1 -maxdepth 1 -type d -exec /bin/sh -c 'cd {}; abuild -r' \;
	git checkout -- . && git clean -fd && git checkout gh-pages
	find ~/packages -maxdepth 1 -mindepth 1 -type d -exec mv -f {} . \;
	echo "$$ABUILD_PUBLIC_KEY" | base64 -d > "$$CIRCLE_PROJECT_USERNAME".rsa.pub
	git add . && git commit -m "Update packages"
	git push https://x-access-token:"$$GITHUB_TOKEN"@$$(git remote get-url --push origin | cut -d@ -f 2 | tr : /) HEAD:refs/heads/gh-pages

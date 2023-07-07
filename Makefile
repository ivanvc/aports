default: build

.PHONY: build
build:
	echo "$$ABUILD_PRIVATE_KEY" | base64 -d > ~/.abuild/alpine-infra@lists.alpinelinux.org-abuild.rsa
	echo "$$ABUILD_PUBLIC_KEY" | base64 -d > ~/.abuild/alpine-infra@lists.alpinelinux.org-abuild.rsa.pub
	doas cp ~/.abuild/alpine-infra@lists.alpinelinux.org-abuild.rsa.pub /etc/apk/keys
	echo 'PACKAGER_PRIVKEY="/home/buildozer/.abuild/alpine-infra@lists.alpinelinux.org-abuild.rsa"' >> ~/.abuild/abuild.conf
	find * -mindepth 1 -maxdepth 1 -type d -exec /bin/sh -c 'cd {}; abuild -r' \;
	git checkout -- . && git clean -fd && git checkout gh-pages
	doas apk add --no-cache tree ; tree ~/packages
	find ~/packages -maxdepth 1 -mindepth 1 -type d -exec mv {} . \;
	cat .gitignore
	git add . && git commit -m "Update packages"
	git push https://x-access-token:"$$GITHUB_TOKEN"@$$(git remote get-url --push origin | cut -d@ -f 2 | tr : /) HEAD:refs/heads/gh-pages

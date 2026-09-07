// Large, centered, stay-until-acknowledged alert panel for the vault timers
// (end-of-day sequence, Pomodoro, ad-hoc timers).  Called from lua/vault.lua as:
//
//     osascript -l JavaScript scripts/timer-alert.js '<json spec>'
//
// Spec keys (all optional): emoji, emoji_size, heading, message, button, title, sound.
// A message containing " — " is split: the part before it is rendered larger
// than the part after, so "30 minutes left — move to writing" reads as a
// headline plus a detail line.
//
// Two extra modes, for checking a design without waiting for a timer:
//     ... timer-alert.js --render out.png '<json spec>'   # screenshot, no window
//     ... timer-alert.js --check                          # exit without showing

ObjC.import("AppKit")

const WIDTH = 720

function makeCenteredLabel(y, text, size, weight) {
	const label = $.NSTextField.alloc.initWithFrame($.NSMakeRect(0, y, WIDTH, size + 14))
	label.stringValue = text
	label.editable = false
	label.selectable = false
	label.bezeled = false
	label.drawsBackground = false
	label.font = $.NSFont.systemFontOfSizeWeight(size, weight)
	label.sizeToFit
	const fitted = label.frame
	const width = Number(fitted.size.width)
	const height = Number(fitted.size.height)
	label.frame = $.NSMakeRect((WIDTH - width) / 2, y, width, height)
	return label
}

function parseSpec(raw) {
	if (!raw) {
		return {}
	}
	try {
		const parsed = JSON.parse(raw)
		return typeof parsed === "object" && parsed !== null ? parsed : { message: raw }
	} catch (e) {
		// Tolerate a bare message string so the script stays usable by hand.
		return { message: raw }
	}
}

function run(argv) {
	const isRender = argv[0] === "--render"
	const isCheck = argv[0] === "--check"
	const spec = parseSpec(isRender ? argv[2] : argv[0])

	const emoji = spec.emoji || "⏰"
	const emojiSize = Number(spec.emoji_size) || 58
	const heading = spec.heading || "Timer"
	const message = spec.message || ""
	const buttonTitle = spec.button || "OK"

	const application = $.NSApplication.sharedApplication
	application.setActivationPolicy($.NSApplicationActivationPolicyAccessory)

	const panel = $.NSPanel.alloc.initWithContentRectStyleMaskBackingDefer(
		$.NSMakeRect(0, 0, WIDTH, 360),
		$.NSWindowStyleMaskTitled,
		$.NSBackingStoreBuffered,
		false
	)
	panel.title = spec.title || heading
	panel.floatingPanel = true
	panel.level = $.NSFloatingWindowLevel
	panel.collectionBehavior =
		$.NSWindowCollectionBehaviorCanJoinAllSpaces |
		$.NSWindowCollectionBehaviorFullScreenAuxiliary
	panel.hidesOnDeactivate = false

	const content = panel.contentView
	// Keep a deliberately oversized emoji clear of the panel top.
	const emojiY = Math.min(245, 360 - (emojiSize + 14) - 8)
	content.addSubview(makeCenteredLabel(emojiY, emoji, emojiSize, $.NSFontWeightRegular))
	content.addSubview(makeCenteredLabel(188, heading, 36, $.NSFontWeightBold))

	const parts = message.split(" — ")
	if (parts.length > 1) {
		content.addSubview(makeCenteredLabel(132, parts[0], 25, $.NSFontWeightSemibold))
		content.addSubview(makeCenteredLabel(96, parts.slice(1).join(" — "), 22, $.NSFontWeightMedium))
	} else if (message) {
		content.addSubview(makeCenteredLabel(108, message, 24, $.NSFontWeightMedium))
	}

	const button = $.NSButton.alloc.initWithFrame($.NSMakeRect(0, 28, 210, 44))
	button.title = buttonTitle
	button.bezelStyle = $.NSBezelStyleRounded
	button.controlSize = $.NSControlSizeLarge
	button.font = $.NSFont.systemFontOfSizeWeight(16, $.NSFontWeightSemibold)
	button.keyEquivalent = "\r"
	button.target = application
	button.action = $.NSSelectorFromString("abortModal")
	button.sizeToFit
	const buttonWidth = Math.max(210, Number(button.frame.size.width) + 48)
	button.frame = $.NSMakeRect((WIDTH - buttonWidth) / 2, 28, buttonWidth, 44)
	content.addSubview(button)

	if (isRender) {
		content.wantsLayer = true
		content.layer.backgroundColor = $.NSColor.windowBackgroundColor.CGColor
		const image = content.bitmapImageRepForCachingDisplayInRect(content.bounds)
		content.cacheDisplayInRectToBitmapImageRep(content.bounds, image)
		const data = image.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $())
		data.writeToFileAtomically(argv[1], false)
		return "ok"
	}

	if (isCheck) {
		return "ok"
	}

	$.NSApp.activateIgnoringOtherApps(true)
	panel.center
	panel.makeKeyAndOrderFront(null)

	const sound = $.NSSound.alloc.initWithContentsOfFileByReference(
		"/System/Library/Sounds/" + (spec.sound || "Glass") + ".aiff",
		true
	)
	sound.volume = 1
	sound.play
	delay(0.9)
	sound.play
	application.runModalForWindow(panel)
	panel.orderOut(null)
}

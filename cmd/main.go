package main

import (
	"fmt"
	"log"
	"time"

	"github.com/delveper/env"
	"github.com/delveper/shadow/app"
)

func main() {
	if err := Run(); err != nil {
		log.Fatalln(err)
	}
}

func Run() error {
	if err := env.LoadVars(); err != nil {
		return fmt.Errorf("load envar: %w", err)
	}

	bot := app.NewBot()

	offset := 0
	for {
		updates, err := bot.PullUpdates(offset)
		if err != nil {
			log.Println(err)
			continue
		}

		for _, update := range updates {
			offset = update.ID + 1

			if update.Message == nil {
				continue
			}

			if update.Message.Chat != nil {
				if err := bot.SendMessage(update.Message.Chat.ID, update.Message.Text); err != nil {
					log.Println(err)
				}
			}
		}

		time.Sleep(1 * time.Second)
	}

	return nil
}